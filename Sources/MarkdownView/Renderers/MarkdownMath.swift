//
//  MarkdownMath.swift
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
struct MarkdownMathRenderer {
    var text: String
    
    func makeBody(configuration: MarkdownRenderConfiguration) -> MarkdownNodeView {
        #if canImport(LaTeXSwiftUI)
        let ranges: [Range<String.Index>]
        if #available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) {
            let latexPrefixOrSuffix = /[\$]{1,2}/
            let latexRegex = Regex {
                latexPrefixOrSuffix
                OneOrMore {
                    CharacterClass.anyOf("$").inverted
                }
                latexPrefixOrSuffix
            }
            ranges = text.matches(of: latexRegex).map(\.range)
        } else {
            let pattern = #"(?<!\\)(\${1,2})([^\$]+?)\1"#
            let regex = try! NSRegularExpression(pattern: pattern)
            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            ranges = regex.matches(in: text, range: nsRange)
                .compactMap({ Range($0.range, in: text) })
        }
        
        var nodeViews: [MarkdownNodeView] = []
        var lastEndIndex = text.startIndex
        
        for range in ranges {
            
            // Add normal text before the current LaTeX match (if any)
            if lastEndIndex < range.lowerBound {
                let normalText = String(text[lastEndIndex..<range.lowerBound])
                nodeViews.append(MarkdownNodeView(Text(normalText)))
            }
            
            // Add the current LaTeX node
            let latexText = String(text[range])
            nodeViews.append(MarkdownNodeView {
                LaTeX(latexText)
                    .font(configuration.fontGroup.inlineMath)
            })
            
            // Update the last processed position
            lastEndIndex = range.upperBound
        }
        
        // Add any remaining text after the last LaTeX match
        if lastEndIndex < text.endIndex {
            let remainingText = String(text[lastEndIndex..<text.endIndex])
            nodeViews.append(MarkdownNodeView(Text(remainingText)))
        }
        
        // If there were no matches, render the entire text as normal
        if nodeViews.isEmpty {
            return MarkdownNodeView {
                Text(text)
            }
        }
        
        return MarkdownNodeView(nodeViews)
        #else
        return MarkdownNodeView(Text(text))
        #endif
    }
}
