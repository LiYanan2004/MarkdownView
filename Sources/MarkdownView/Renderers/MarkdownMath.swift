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
                    .font(.footnote)
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
    
    private func processParenDelimiters() -> [(Range<String.Index>, String)] {
        let parenRegex = Regex {
            "\\("
            Capture {
                OneOrMore(.anyNonNewline.union(.newlineSequence))
                ZeroOrMore {
                    NegativeLookahead {
                        "\\)"
                    }
                    CharacterClass.any
                }
            }
            "\\)"
        }
        .dotMatchesNewlines()
        
        var matches: [(Range<String.Index>, String)] = []
        for match in text.matches(of: parenRegex) {
            let range = match.range
            let content = String(match.output.1)
            let latex = "$" + content + "$"
            matches.append((range, latex))
        }
        
        return matches
    }

    private func processBracketDelimiters() -> [(Range<String.Index>, String)] {
        let parenRegex = Regex {
            "\\["
            Capture {
                OneOrMore(.anyNonNewline.union(.newlineSequence))
                ZeroOrMore {
                    NegativeLookahead {
                        "\\]"
                    }
                    CharacterClass.any
                }
            }
            "\\]"
        }
        .dotMatchesNewlines()
        
        var matches: [(Range<String.Index>, String)] = []
        for match in text.matches(of: parenRegex) {
            let range = match.range
            let content = String(match.output.1)
            let latex = "$$" + content + "$$"
            matches.append((range, latex))
        }
        
        return matches
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        MarkdownView(#"Inline math with `$`: $ \sqrt{3x-1}+(1+x)^2 $"#)
        
        MarkdownView(#"Inline math with `\(...\)`: \(\sqrt{3x-1}+(1+x)^2\)"#)
        
        MarkdownView(#"""
        **The Cauchy-Schwarz Inequality** with `$$`
        $$ \left( \sum_{k=1}^n a_k b_k \right)^2 \leq \left( \sum_{k=1}^n a_k^2 \right) \left( \sum_{k=1}^n b_k^2 \right) $$
        """#)
        
        MarkdownView(#"""
        Sure! Here's the calculation presented in LaTeX:

        \[ \text{MME from MS Contin} = 60 \, \text{mg} \times 2 = 120 \, \text{mg of morphine/day} = 120 \, \text{MME} \]

        \[
        \text{MME from Percocet} = 7.5 \, \text{mg} \times 4 = 30 \, \text{mg of oxycodone/day} 
        \]

        \[
        \text{Converted to MME} = 30 \, \text{mg} \times 1.5 = 45 \, \text{MME}
        \]

        \[
        \text{Total MME} = 120 \, \text{MME (from MS Contin)} + 45 \, \text{MME (from Percocet)} = 165 \, \text{MME}
        \]

        Thus, the combined total is \( \text{165 MME} \).
        """#)
    }
    .padding()
    .markdownMathRenderingEnabled()
}
