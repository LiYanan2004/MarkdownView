//
//  MarkdownMathPreprocessor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/16.
//

import Foundation
import Markdown

@_documentation(visibility: internal)
public struct MarkdownMathPreprocessor: Sendable, Hashable {
    public struct Result: Sendable, Hashable {
        public let markdown: String
        public let context: MarkdownMathContext
        let replacements: [Replacement]

        public init(
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
    
    public func preprocess(_ markdown: String) -> String {
        preprocessingResult(for: markdown).markdown
    }
    
    public init() {
        
    }

    public func preprocessingResult(for markdown: String) -> MarkdownMathPreprocessor.Result {
        var mathRangesResolver = MathParsableRangesResolver()
        mathRangesResolver.visit(
            Document(
                parsing: markdown,
                options: ParseOptions().union(.parseBlockDirectives)
            )
        )

        return MathPlaceholderSubstituter.process(
            markdown,
            parsableRanges: mathRangesResolver.resolve(in: markdown)
        )
    }
}

extension MarkdownMathPreprocessor {
    struct Replacement: Sendable, Hashable {
        let sourceRange: Range<Int>
        let processedRange: Range<Int>
    }

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

    static public func inlinePlaceholder(for identifier: UUID) -> String {
        "markdownview-inline-math-\(identifier.uuidString)"
    }
    
    static public func displayPlaceholder(for identifier: UUID) -> String {
        "@math(uuid: \"\(identifier.uuidString)\")"
    }

    static func displayPlaceholderIdentifier(in text: String) -> UUID? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let prefix = "@math(uuid: \""
        let suffix = "\")"

        guard trimmedText.hasPrefix(prefix),
              trimmedText.hasSuffix(suffix)
        else {
            return nil
        }

        let identifierStartIndex = trimmedText.index(
            trimmedText.startIndex,
            offsetBy: prefix.count
        )
        let identifierEndIndex = trimmedText.index(
            trimmedText.endIndex,
            offsetBy: -suffix.count
        )
        return UUID(uuidString: String(trimmedText[identifierStartIndex..<identifierEndIndex]))
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
