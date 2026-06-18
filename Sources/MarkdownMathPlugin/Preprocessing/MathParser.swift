//
//  MathParser.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//  Credits to colinc86/LaTeXSwiftUI
//

import Foundation

package struct MathParser {
    package var text: any StringProtocol

    package init(text: some StringProtocol) {
        self.text = text
    }

    package var mathRepresentations: [MathRepresentation] {
        var stack = [MathRepresentation.Kind]()
        var index = text.startIndex
        var startIndex = index
        var endIndex = index
        var representations: [MathRepresentation] = []

        inputLoop: while index < text.endIndex {
            let remaining = text[index...]

            if !stack.isEmpty {
                for type in MathRepresentation.Kind.allCases {
                    let end = type.rightTerminator
                    if remaining.hasPrefix(end) {
                        if index > text.startIndex && text[text.index(before: index)] == "\\" {
                            index = text.index(index, offsetBy: end.count)
                            continue inputLoop
                        }

                        endIndex = text.index(index, offsetBy: end.count)

                        if stack.last == type {
                            stack.removeLast()

                            if stack.isEmpty {
                                representations.append(
                                    MathRepresentation(
                                        kind: type,
                                        range: startIndex..<endIndex
                                    )
                                )
                            }
                        }
                        index = endIndex
                        continue inputLoop
                    }
                }
            }

            for type in MathRepresentation.Kind.allCases {
                let start = type.leftTerminator
                if remaining.hasPrefix(start) {
                    if type.requiresLineBoundary && !text.isAtLineBoundary(index) {
                        index = text.index(index, offsetBy: start.count)
                        continue inputLoop
                    }

                    if index > text.startIndex && text[text.index(before: index)] == "\\" {
                        index = text.index(index, offsetBy: start.count)
                        continue inputLoop
                    }

                    if stack.isEmpty {
                        startIndex = index
                    }

                    stack.append(type)
                    index = text.index(index, offsetBy: start.count)
                    continue inputLoop
                }
            }

            index = text.index(after: index)
        }

        return representations
    }
}

extension MathParser {
    package struct MathRepresentation: Sendable, Hashable {
        package var kind: Kind
        package var range: Range<String.Index>
    }
}

extension MathParser.MathRepresentation {
    package enum Kind: Hashable, Sendable, CaseIterable {
        /// An inline equation component.
        ///
        /// - Example: `$x^2$`
        case inlineEquation

        /// An inline equation component.
        ///
        /// - Example: `\(x^2\)`
        case inlineParenthesesEquation

        /// A TeX-style block equation.
        ///
        /// - Example: `$$x^2$$`.
        case texEquation

        /// A block equation.
        ///
        /// - Example: `\[x^2\]`
        case blockEquation

        /// A named equation component.
        ///
        /// - Example: `\begin{equation}x^2\end{equation}`
        case namedEquation

        /// A named equation component.
        ///
        /// - Example: `\begin{equation*}x^2\end{equation*}`
        case namedNoNumberEquation

        /// The component's left terminator.
        var leftTerminator: String {
            switch self {
            case .inlineEquation: "$"
            case .inlineParenthesesEquation: "\\("
            case .texEquation: "$$"
            case .blockEquation: "\\["
            case .namedEquation: "\\begin{equation}"
            case .namedNoNumberEquation: "\\begin{equation*}"
            }
        }

        /// The component's right terminator.
        var rightTerminator: String {
            switch self {
            case .inlineEquation: "$"
            case .inlineParenthesesEquation: "\\)"
            case .texEquation: "$$"
            case .blockEquation: "\\]"
            case .namedEquation: "\\end{equation}"
            case .namedNoNumberEquation: "\\end{equation*}"
            }
        }

        /// Whether this component is inline.
        var inline: Bool {
            switch self {
            case .inlineEquation, .inlineParenthesesEquation: true
            default: false
            }
        }

        var requiresLineBoundary: Bool {
            switch self {
            case .blockEquation:
                true
            default:
                false
            }
        }

        package static let allCases: [Kind] = [
            .namedNoNumberEquation,
            .namedEquation,
            .blockEquation,
            .texEquation,
            .inlineEquation,
            .inlineParenthesesEquation,
        ]
    }
}

fileprivate extension StringProtocol {
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
}
