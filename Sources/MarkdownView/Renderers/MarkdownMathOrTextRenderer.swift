//
//  MarkdownMathOrTextRenderer.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI
import RegexBuilder
#if canImport(LaTeXSwiftUI)
import LaTeXSwiftUI
import MathJaxSwift
#endif

@MainActor
struct MarkdownMathOrTextRenderer {
    var text: String
    
    func makeBody(configuration: MarkdownRenderConfiguration) -> MarkdownNodeView {
        #if canImport(LaTeXSwiftUI)
        var nodeViews: [MarkdownNodeView] = []
        var processingIndex = text.startIndex
        
        for range in mathRanges {
            // Add normal text before the current LaTeX match (if any)
            if processingIndex < range.lowerBound {
                let normalText = String(text[processingIndex..<range.lowerBound])
                nodeViews.append(MarkdownNodeView(Text(normalText)))
            }
            
            // Add the current LaTeX node
            let latexText = String(text[range])
            nodeViews.append(MarkdownNodeView {
                LaTeX(latexText)
                    .font(configuration.fontGroup.inlineMath)
            })
            
            processingIndex = range.upperBound
        }
        
        // Add any remaining text after the last LaTeX match
        if processingIndex < text.endIndex {
            let remainingText = String(text[processingIndex..<text.endIndex])
            nodeViews.append(MarkdownNodeView(Text(remainingText)))
        }
        
        return MarkdownNodeView(nodeViews)
        #else
        return MarkdownNodeView(Text(text))
        #endif
    }
}

extension MarkdownMathOrTextRenderer {
    enum MathPattern: Hashable, Sendable, CaseIterable {
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
            case .inlineEquation: return "$"
            case .inlineParenthesesEquation: return "\\("
            case .texEquation: return "$$"
            case .blockEquation: return "\\["
            case .namedEquation: return "\\begin{equation}"
            case .namedNoNumberEquation: return "\\begin{equation*}"
            }
        }
        
        /// The component's right terminator.
        var rightTerminator: String {
            switch self {
            case .inlineEquation: return "$"
            case .inlineParenthesesEquation: return "\\)"
            case .texEquation: return "$$"
            case .blockEquation: return "\\]"
            case .namedEquation: return "\\end{equation}"
            case .namedNoNumberEquation: return "\\end{equation*}"
            }
        }
        
        /// Whether or not this component is inline.
        var inline: Bool {
            switch self {
            case .inlineEquation, .inlineParenthesesEquation: return true
            default: return false
            }
        }
        
        static let allCases: [MathPattern] = [
            .namedNoNumberEquation,
            .namedEquation,
            .blockEquation,
            .texEquation,
            .inlineEquation,
            .inlineParenthesesEquation
        ]
    }
}

// MARK: - Auxiliary

extension MarkdownMathOrTextRenderer {
    /*
     Credits to colinc86/LaTeXSwiftUI
     */
    @_spi(MarkdownViewTesting)
    public var mathRanges: [Range<String.Index>] {
        var stack = [MathPattern]()
        var index = text.startIndex
        var startIndex = index
        var endIndex = index
        var mathRanges: [Range<String.Index>] = []
        
        inputLoop: while index < text.endIndex {
            let remaining = text[index...]
            
            if !stack.isEmpty {
                for type in MathPattern.allCases {
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
                                mathRanges.append(startIndex..<endIndex)
                            }
                        }
                        index = endIndex
                        continue inputLoop
                    }
                }
            }
            
            for type in MathPattern.allCases {
                let start = type.leftTerminator
                if remaining.hasPrefix(start) {
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
        
        return mathRanges
    }
}
