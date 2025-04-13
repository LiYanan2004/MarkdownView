//
//  InlineMathOrText.swift
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

@preconcurrency
@MainActor
struct InlineMathOrText {
    var text: String
    
    @preconcurrency
    @MainActor
    func makeBody(configuration: MarkdownRenderConfiguration) -> MarkdownNodeView {
        #if canImport(LaTeXSwiftUI)
        let mathParser = MathParser(text: text)
        var nodeViews: [MarkdownNodeView] = []
        var processingIndex = text.startIndex
        
        for math in mathParser.mathRepresentations {
            let range = math.range
            
            // Add normal text before the current LaTeX match (if any)
            if processingIndex < range.lowerBound {
                let normalText = String(text[processingIndex..<range.lowerBound])
                nodeViews.append(MarkdownNodeView(Text(normalText)))
            }
            
            // Add the current LaTeX node
            let latexText = String(text[range])
            nodeViews.append(MarkdownNodeView {
                LaTeX(latexText)
                    .blockMode(.alwaysInline)
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
