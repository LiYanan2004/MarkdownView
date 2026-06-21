//
//  MathParser.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import Foundation

struct MathParser {
    var text: any StringProtocol

    init(text: some StringProtocol) {
        self.text = text
    }

    var mathRepresentations: [MathRepresentation] {
        var representations: [MathRepresentation] = []
        var index = text.startIndex

        while index < text.endIndex {
            guard !text.isEscaped(at: index) else {
                index = text.index(after: index)
                continue
            }

            if let representation = delimitedRepresentation(startingAt: index)
                ?? environmentRepresentation(startingAt: index) {
                representations.append(representation)
                index = representation.range.upperBound
            } else {
                index = text.index(after: index)
            }
        }

        return representations
    }

    private func delimitedRepresentation(
        startingAt startIndex: String.Index
    ) -> MathRepresentation? {
        let remainingText = text[startIndex...]

        for kind in MathRepresentation.Kind.delimitedKinds {
            guard remainingText.hasPrefix(kind.leftTerminator) else {
                continue
            }
            guard !kind.requiresLineBoundary || text.isAtLineBoundary(startIndex) else {
                continue
            }

            var endTerminatorIndex = text.index(
                startIndex,
                offsetBy: kind.leftTerminator.count
            )
            while endTerminatorIndex < text.endIndex {
                if !text.isEscaped(at: endTerminatorIndex),
                   text[endTerminatorIndex...].hasPrefix(kind.rightTerminator) {
                    let endIndex = text.index(
                        endTerminatorIndex,
                        offsetBy: kind.rightTerminator.count
                    )
                    return MathRepresentation(kind: kind, range: startIndex..<endIndex)
                }
                endTerminatorIndex = text.index(after: endTerminatorIndex)
            }
        }

        return nil
    }

    private func environmentRepresentation(
        startingAt startIndex: String.Index
    ) -> MathRepresentation? {
        guard let openingToken = text.environmentToken(at: startIndex),
              openingToken.boundary == .begin,
              let kind = MathRepresentation.Kind(environmentName: openingToken.name) else {
            return nil
        }

        var environmentNames = [openingToken.name]
        var index = openingToken.range.upperBound

        while index < text.endIndex {
            defer { index = text.index(after: index) }

            guard !text.isEscaped(at: index),
                  let token = text.environmentToken(at: index) else {
                continue
            }

            switch token.boundary {
            case .begin:
                environmentNames.append(token.name)
            case .end where environmentNames.last == token.name:
                environmentNames.removeLast()
                if environmentNames.isEmpty {
                    return MathRepresentation(
                        kind: kind,
                        range: startIndex..<token.range.upperBound
                    )
                }
            case .end:
                continue
            }

            index = text.index(before: token.range.upperBound)
        }

        return nil
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

        fileprivate static let delimitedKinds: [Kind] = [
            .texEquation,
            .inlineEquation,
            .inlineParenthesesEquation,
            .blockEquation,
        ]

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
