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
        // Process different types of LaTeX delimiters
        let dollarMatches = processDollarDelimiters()
        let parenMatches = processParenDelimiters()
        let bracketMatches = processBracketDelimiters()
        
        // Combine all matches and sort by position
        var allMatches = dollarMatches + parenMatches + bracketMatches
        allMatches.sort { $0.0.lowerBound < $1.0.lowerBound }
        
        var nodeViews: [MarkdownNodeView] = []
        var lastEndIndex = text.startIndex
        
        for (range, latex) in allMatches {
            // Add normal text before the current LaTeX match (if any)
            if lastEndIndex < range.lowerBound {
                let normalText = String(text[lastEndIndex..<range.lowerBound])
                nodeViews.append(MarkdownNodeView(Text(normalText)))
            }
            
            // Add the current LaTeX node
            nodeViews.append(MarkdownNodeView {
                LaTeX(latex)
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
    
    // Process $...$ and $$...$$ delimiters (already implemented)
    private func processDollarDelimiters() -> [(Range<String.Index>, String)] {
        let latexPrefixOrSuffix = /[\$]{1,2}/
        let latexRegex = Regex {
            latexPrefixOrSuffix
            OneOrMore {
                CharacterClass.anyOf("$").inverted
            }
            latexPrefixOrSuffix
        }
        
        var matches: [(Range<String.Index>, String)] = []
        for match in text.matches(of: latexRegex) {
            let range = match.range
            let latex = String(text[range])
            
            matches.append((range, latex))
        }
        
        return matches
    }
    
    // Process \(...\) delimiters
    private func processParenDelimiters() -> [(Range<String.Index>, String)] {
        var matches: [(Range<String.Index>, String)] = []
        
        // Find all occurrences of \(
        var searchRange = text.startIndex..<text.endIndex
        while let openRange = text.range(of: "\\(", range: searchRange) {
            // Look for the corresponding \) after the \(
            let afterOpenRange = openRange.upperBound..<text.endIndex
            if let closeRange = text.range(of: "\\)", range: afterOpenRange) {
                // Found a pair of \( and \)
                let fullRange = openRange.lowerBound..<closeRange.upperBound
                let content = String(text[openRange.upperBound..<closeRange.lowerBound])
                
                // Convert to LaTeX format
                let latex = "$" + content + "$"
                
                matches.append((fullRange, latex)) // Inline math
                
                // Update search range for next iteration
                searchRange = closeRange.upperBound..<text.endIndex
            } else {
                // No matching \) found, move past this \(
                searchRange = openRange.upperBound..<text.endIndex
            }
        }
        
        return matches
    }
    
    // Process \[...\] delimiters
    private func processBracketDelimiters() -> [(Range<String.Index>, String)] {
        var matches: [(Range<String.Index>, String)] = []
        
        // Find all occurrences of \[
        var searchRange = text.startIndex..<text.endIndex
        while let openRange = text.range(of: "\\[", range: searchRange) {
            // Look for the corresponding \] after the \[
            let afterOpenRange = openRange.upperBound..<text.endIndex
            if let closeRange = text.range(of: "\\]", range: afterOpenRange) {
                // Found a pair of \[ and \]
                let fullRange = openRange.lowerBound..<closeRange.upperBound
                let content = String(text[openRange.upperBound..<closeRange.lowerBound])
                
                // Convert to LaTeX format
                let latex = "$$" + content + "$$"
                
                matches.append((fullRange, latex)) // Display math
                
                // Update search range for next iteration
                searchRange = closeRange.upperBound..<text.endIndex
            } else {
                // No matching \] found, move past this \[
                searchRange = openRange.upperBound..<text.endIndex
            }
        }
        
        return matches
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        MarkdownView(#"Inline math with `$`: $\sqrt{3x-1}+(1+x)^2$"#)
        
        MarkdownView(#"Inline math with `\(...\)`: \(\sqrt{3x-1}+(1+x)^2\)"#)
        
        MarkdownView(#"""
        **The Cauchy-Schwarz Inequality** with `$$`
        $$\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)$$
        """#)
        
        MarkdownView(#"""
        **The Cauchy-Schwarz Inequality** with `\[...\]`
        \[\left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right)\]
        """#)
    }
    .padding()
    .markdownMathRenderingEnabled()
}
