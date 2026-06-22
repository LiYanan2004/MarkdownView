//
//  MathParser.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import Foundation

struct MathParser {
    var text: Substring

    init(text: String) {
        self.text = text[...]
    }

    init(text: Substring) {
        self.text = text
    }

    var mathRepresentations: [MathRepresentation] {
        mergedNonOverlappingRepresentations(
            from: delimitedRepresentations() + environmentRepresentations()
        )
    }

    private func delimitedRepresentations() -> [MathRepresentation] {
        let copiedText = String(text)
        let searchRange = NSRange(copiedText.startIndex..<copiedText.endIndex, in: copiedText)
        var representations: [MathRepresentation] = []
        representations.reserveCapacity(4)

        Self.delimitedRegularExpression.enumerateMatches(
            in: copiedText,
            options: [],
            range: searchRange
        ) { match, _, _ in
            guard let match else {
                return
            }

            let groups: [(rangeIndex: Int, kind: MathRepresentation.Kind)] = [
                (1, .texEquation),
                (2, .inlineParenthesesEquation),
                (3, .blockEquation),
                (4, .inlineEquation),
            ]

            for group in groups {
                let nsRange = match.range(at: group.rangeIndex)
                guard nsRange.location != NSNotFound,
                      let copiedRange = Range(nsRange, in: copiedText),
                      let sourceRange = originalRange(
                          fromCopiedRange: copiedRange,
                          in: copiedText
                      ),
                      isValidDelimitedMatch(
                          kind: group.kind,
                          range: sourceRange
                      )
                else {
                    continue
                }

                representations.append(
                    MathRepresentation(
                        kind: group.kind,
                        range: sourceRange
                    )
                )
                break
            }
        }

        return representations
    }

    private func environmentRepresentations() -> [MathRepresentation] {
        var representations: [MathRepresentation] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            guard !text.isEscaped(at: currentIndex) else {
                currentIndex = text.index(after: currentIndex)
                continue
            }

            guard let openingToken = text.environmentToken(at: currentIndex),
                  openingToken.boundary == .begin,
                  let kind = MathRepresentation.Kind(environmentName: openingToken.name)
            else {
                currentIndex = text.index(after: currentIndex)
                continue
            }

            if let environmentRange = environmentRange(startingWith: openingToken) {
                representations.append(
                    MathRepresentation(
                        kind: kind,
                        range: environmentRange
                    )
                )
                currentIndex = environmentRange.upperBound
            } else {
                currentIndex = openingToken.range.upperBound
            }
        }

        return representations
    }

    private func environmentRange(
        startingWith openingToken: MathEnvironmentToken<String.Index>
    ) -> Range<String.Index>? {
        var environmentNames = [openingToken.name]
        var currentIndex = openingToken.range.upperBound

        while currentIndex < text.endIndex {
            defer { currentIndex = text.index(after: currentIndex) }

            guard !text.isEscaped(at: currentIndex),
                  let token = text.environmentToken(at: currentIndex) else {
                continue
            }

            switch token.boundary {
            case .begin:
                environmentNames.append(token.name)
            case .end where environmentNames.last == token.name:
                environmentNames.removeLast()
                if environmentNames.isEmpty {
                    return openingToken.range.lowerBound..<token.range.upperBound
                }
            case .end:
                continue
            }

            currentIndex = text.index(before: token.range.upperBound)
        }

        return nil
    }

    private func mergedNonOverlappingRepresentations(
        from representations: [MathRepresentation]
    ) -> [MathRepresentation] {
        let sortedRepresentations = representations.sorted { leftHandRepresentation, rightHandRepresentation in
            if leftHandRepresentation.range.lowerBound != rightHandRepresentation.range.lowerBound {
                return leftHandRepresentation.range.lowerBound < rightHandRepresentation.range.lowerBound
            }

            return leftHandRepresentation.range.upperBound > rightHandRepresentation.range.upperBound
        }

        var mergedRepresentations: [MathRepresentation] = []
        mergedRepresentations.reserveCapacity(sortedRepresentations.count)

        for representation in sortedRepresentations {
            if let previousRepresentation = mergedRepresentations.last,
               previousRepresentation.range.overlaps(representation.range) {
                continue
            }

            mergedRepresentations.append(representation)
        }

        return mergedRepresentations
    }

    private func originalRange(
        fromCopiedRange copiedRange: Range<String.Index>,
        in copiedText: String
    ) -> Range<String.Index>? {
        let lowerBoundOffset = copiedText.distance(
            from: copiedText.startIndex,
            to: copiedRange.lowerBound
        )
        let upperBoundOffset = copiedText.distance(
            from: copiedText.startIndex,
            to: copiedRange.upperBound
        )

        guard let lowerBound = text.index(
            text.startIndex,
            offsetBy: lowerBoundOffset,
            limitedBy: text.endIndex
        ),
        let upperBound = text.index(
            text.startIndex,
            offsetBy: upperBoundOffset,
            limitedBy: text.endIndex
        ) else {
            return nil
        }

        return lowerBound..<upperBound
    }

    private func isValidDelimitedMatch(
        kind: MathRepresentation.Kind,
        range: Range<String.Index>
    ) -> Bool {
        guard !text.isEscaped(at: range.lowerBound) else {
            return false
        }

        let closingTerminatorStartIndex = text.index(
            range.upperBound,
            offsetBy: -kind.rightTerminator.count
        )
        guard !text.isEscaped(at: closingTerminatorStartIndex) else {
            return false
        }

        if kind == .blockEquation {
            return text.isAtLineBoundary(range.lowerBound)
        }

        return true
    }
}

extension MathParser {
    struct MathRepresentation: Sendable, Hashable {
        var kind: Kind
        var range: Range<String.Index>
    }
}

extension MathParser.MathRepresentation {
    enum Kind: Hashable, Sendable {
        /// An inline equation delimited by `$`.
        case inlineEquation

        /// An inline equation delimited by `\(` and `\)`.
        case inlineParenthesesEquation

        /// A display equation delimited by `$$`.
        case texEquation

        /// A display equation delimited by `\[` and `\]`.
        case blockEquation

        /// A display equation delimited by an `equation` environment.
        case namedEquation

        /// A display equation delimited by an `equation*` environment.
        case namedNoNumberEquation

        /// A standalone environment that SwiftMath parses directly.
        case swiftMathEnvironment(String)

        var leftTerminator: String {
            switch self {
            case .inlineEquation: "$"
            case .inlineParenthesesEquation: "\\("
            case .texEquation: "$$"
            case .blockEquation: "\\["
            case .namedEquation: "\\begin{equation}"
            case .namedNoNumberEquation: "\\begin{equation*}"
            case .swiftMathEnvironment(let name): "\\begin{\(name)}"
            }
        }

        var rightTerminator: String {
            switch self {
            case .inlineEquation: "$"
            case .inlineParenthesesEquation: "\\)"
            case .texEquation: "$$"
            case .blockEquation: "\\]"
            case .namedEquation: "\\end{equation}"
            case .namedNoNumberEquation: "\\end{equation*}"
            case .swiftMathEnvironment(let name): "\\end{\(name)}"
            }
        }

        var inline: Bool {
            switch self {
            case .inlineEquation, .inlineParenthesesEquation:
                true
            default:
                false
            }
        }

        var preservesTerminatorsWhenRendering: Bool {
            if case .swiftMathEnvironment = self {
                return true
            }
            return false
        }

        fileprivate var requiresLineBoundary: Bool {
            self == .blockEquation
        }

        fileprivate init?(environmentName: String) {
            switch environmentName {
            case "equation":
                self = .namedEquation
            case "equation*":
                self = .namedNoNumberEquation
            case let name where Self.swiftMathEnvironmentNames.contains(name):
                self = .swiftMathEnvironment(name)
            default:
                return nil
            }
        }

        private static let swiftMathEnvironmentNames: Set<String> = [
            "matrix",
            "pmatrix",
            "bmatrix",
            "Bmatrix",
            "vmatrix",
            "Vmatrix",
            "eqalign",
            "split",
            "aligned",
            "displaylines",
            "gather",
            "eqnarray",
            "cases",
        ]
    }
}

private extension MathParser {
    static let delimitedRegularExpression = try! NSRegularExpression(
            pattern: [
                #"(\$\$[\s\S]*?\$\$)"#,
                #"(\\\([\s\S]*?\\\))"#,
                #"(?:(?<=^)|(?<=\n))[ \t]*(\\\[[\s\S]*?\\\])"#,
                #"(\$(?!\s)([^\r\n$]+?)(?<!\s)\$(?!\d))"#,
            ].joined(separator: "|"),
            options: []
        )
}

fileprivate extension StringProtocol {
    func isEscaped(at index: Index) -> Bool {
        var backslashCount = 0
        var currentIndex = index

        while currentIndex > startIndex {
            let previousIndex = self.index(before: currentIndex)
            guard self[previousIndex] == "\\" else {
                break
            }
            backslashCount += 1
            currentIndex = previousIndex
        }

        return !backslashCount.isMultiple(of: 2)
    }

    func isAtLineBoundary(_ index: Index) -> Bool {
        var currentIndex = index
        while currentIndex > startIndex {
            let previousIndex = self.index(before: currentIndex)
            if self[previousIndex] == "\n" {
                let lineStartIndex = self.index(after: previousIndex)
                return self[lineStartIndex..<index].allSatisfy(\.isWhitespace)
            }
            currentIndex = previousIndex
        }

        return self[startIndex..<index].allSatisfy(\.isWhitespace)
    }

    func environmentToken(at index: Index) -> MathEnvironmentToken<Index>? {
        let remainingText = self[index...]
        let boundary: MathEnvironmentToken<Index>.Boundary
        let nameStartIndex: Index

        if remainingText.hasPrefix("\\begin{") {
            boundary = .begin
            nameStartIndex = self.index(index, offsetBy: 7)
        } else if remainingText.hasPrefix("\\end{") {
            boundary = .end
            nameStartIndex = self.index(index, offsetBy: 5)
        } else {
            return nil
        }

        guard let closingBraceIndex = self[nameStartIndex...].firstIndex(of: "}") else {
            return nil
        }

        let tokenEndIndex = self.index(after: closingBraceIndex)
        return MathEnvironmentToken(
            boundary: boundary,
            name: String(self[nameStartIndex..<closingBraceIndex]),
            range: index..<tokenEndIndex
        )
    }
}

fileprivate struct MathEnvironmentToken<Index: Comparable> {
    enum Boundary {
        case begin
        case end
    }

    var boundary: Boundary
    var name: String
    var range: Range<Index>
}
