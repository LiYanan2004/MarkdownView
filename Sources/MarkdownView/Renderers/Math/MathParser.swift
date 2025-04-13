//
//  MathParser.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI
#if canImport(LaTeXSwiftUI)
import LaTeXSwiftUI
import MathJaxSwift
#endif

/*
 Credits to colinc86/LaTeXSwiftUI
 */
@_spi(MarkdownMath)
public struct MathParser {
    public var text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var mathRepresentations: [MathRepresentation] {
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
    public struct MathRepresentation: Sendable, Hashable {
        public var kind: Kind
        public var range: Range<String.Index>
    }
}

extension MathParser.MathRepresentation {
    public enum Kind: Hashable, Sendable, CaseIterable {
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
        
        public static let allCases: [Kind] = [
            .namedNoNumberEquation,
            .namedEquation,
            .blockEquation,
            .texEquation,
            .inlineEquation,
            .inlineParenthesesEquation,
        ]
    }
}
