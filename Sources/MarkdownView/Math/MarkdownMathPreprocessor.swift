//
//  MarkdownMathPreprocessor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation
import Markdown

struct MarkdownMathPreprocessor: Sendable, Hashable {
    struct Result: Sendable, Hashable {
        let markdown: String
        let context: MarkdownMathContext
        let replacements: [Replacement]

        init(
            markdown: String,
            context: MarkdownMathContext
        ) {
            self.init(
                markdown: markdown,
                context: context,
                replacements: []
            )
        }

        init(
            markdown: String,
            context: MarkdownMathContext,
            replacements: [Replacement]
        ) {
            self.markdown = markdown
            self.context = context
            self.replacements = replacements
        }
    }
    
    func preprocess(_ markdown: String) -> String {
        preprocessingResult(for: markdown).markdown
    }

    func preprocessingResult(
        for markdown: String,
        requiresBlockDirectiveParsing: Bool = false
    ) -> MarkdownMathPreprocessor.Result {
        guard Self.containsSupportedMathSyntax(in: markdown) else {
            return MarkdownMathPreprocessor.Result(
                markdown: markdown,
                context: MarkdownMathContext()
            )
        }

        let parseOptions: ParseOptions = requiresBlockDirectiveParsing
            ? [.parseBlockDirectives]
            : []
        var mathRangesResolver = MathParsableRangesResolver()
        mathRangesResolver.visit(
            Document(
                parsing: markdown,
                options: parseOptions
            )
        )

        return MathPlaceholderSubstituter.process(
            markdown,
            parsableRanges: mathRangesResolver.resolve(in: markdown)
        )
    }
}

extension MarkdownMathPreprocessor {
    enum PlaceholderKind: String, Sendable, Hashable {
        case inline
        case display
    }

    struct PlaceholderMatch: Sendable, Hashable {
        let kind: PlaceholderKind
        let identifier: UUID
    }

    struct Replacement: Sendable, Hashable {
        let sourceRange: Range<Int>
        let processedRange: Range<Int>
    }

    private static let placeholderPrefix = "markdownview-math("
    private static let placeholderSuffix = ")"

    static func stableIdentifier(
        matchedText: String,
        sourceRange: Range<Int>
    ) -> UUID {
        let identifierSeed = "\(sourceRange.lowerBound):\(sourceRange.upperBound):\(matchedText)"
        let identifierSeedBytes = Array(identifierSeed.utf8)
        let mostSignificantBits = stableHash64(
            bytes: identifierSeedBytes,
            offsetBasis: 14_695_981_039_346_656_037
        )
        let leastSignificantBits = stableHash64(
            bytes: identifierSeedBytes,
            offsetBasis: 1_099_511_628_211
        )

        var uuidBytes: [UInt8] = []
        uuidBytes.reserveCapacity(16)
        uuidBytes.append(contentsOf: withUnsafeBytes(of: mostSignificantBits.bigEndian, Array.init))
        uuidBytes.append(contentsOf: withUnsafeBytes(of: leastSignificantBits.bigEndian, Array.init))

        uuidBytes[6] = (uuidBytes[6] & 0x0F) | 0x50
        uuidBytes[8] = (uuidBytes[8] & 0x3F) | 0x80

        return UUID(uuid: (
            uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
            uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
            uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
            uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]
        ))
    }

    private static func stableHash64(
        bytes: [UInt8],
        offsetBasis: UInt64
    ) -> UInt64 {
        bytes.reduce(offsetBasis) { partialHash, byte in
            (partialHash ^ UInt64(byte)) &* 1_099_511_628_211
        }
    }

    static func containsSupportedMathSyntax(in markdown: String) -> Bool {
        markdown.contains("$")
            || markdown.contains(#"\("#)
            || markdown.contains(#"\["#)
            || markdown.contains(#"\begin{"#)
    }

    static func placeholder(
        for identifier: UUID,
        kind: PlaceholderKind
    ) -> String {
        "\(placeholderPrefix)\(kind.rawValue):\(identifier.uuidString)\(placeholderSuffix)"
    }

    static func inlinePlaceholder(for identifier: UUID) -> String {
        placeholder(for: identifier, kind: .inline)
    }

    static func displayPlaceholder(for identifier: UUID) -> String {
        placeholder(for: identifier, kind: .display)
    }

    static func placeholderMatch(in text: String) -> PlaceholderMatch? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.hasPrefix(placeholderPrefix),
              trimmedText.hasSuffix(placeholderSuffix)
        else {
            return nil
        }

        let payloadStartIndex = trimmedText.index(
            trimmedText.startIndex,
            offsetBy: placeholderPrefix.count
        )
        let payloadEndIndex = trimmedText.index(
            trimmedText.endIndex,
            offsetBy: -placeholderSuffix.count
        )
        let payload = trimmedText[payloadStartIndex..<payloadEndIndex]
        let components = payload.split(
            separator: ":",
            maxSplits: 1,
            omittingEmptySubsequences: false
        )
        guard components.count == 2,
              let kind = PlaceholderKind(rawValue: String(components[0])),
              let identifier = UUID(uuidString: String(components[1]))
        else {
            return nil
        }

        return PlaceholderMatch(kind: kind, identifier: identifier)
    }

    static func displayPlaceholderIdentifier(in text: String) -> UUID? {
        guard let placeholderMatch = placeholderMatch(in: text),
              placeholderMatch.kind == .display
        else {
            return nil
        }

        return placeholderMatch.identifier
    }
}

extension MarkdownMathPreprocessor.Result {
    var inlineMathStorage: [UUID: String] {
        context.inlineMathStorage
    }
    
    var displayMathStorage: [UUID: String] {
        context.displayMathStorage
    }
}
