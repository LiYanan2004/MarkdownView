//
//  MathFirstMarkdownViewRenderer.ParsingRangesExtractor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/17.
//

import Markdown

extension MathFirstMarkdownViewRenderer {
    struct ParsingRangesExtractor: MarkupWalker {
        private var resolvableExcludedRanges: [any MarkdownTextRangesResolvable] = []
        
        func parsableRanges(in text: String) -> [Range<String.Index>] {
            var allowedRanges: [Range<String.Index>] = []
            let excludedRanges = resolvableExcludedRanges.flatMap {
                $0.resolve(in: text)
            }

            let fullRange = text.startIndex..<text.endIndex
            let sortedExcluded = excludedRanges.sorted { $0.lowerBound < $1.lowerBound }
            var currentStart = fullRange.lowerBound
            
            for ex in sortedExcluded {
                if currentStart < ex.lowerBound {
                    allowedRanges.append(currentStart..<ex.lowerBound)
                }
                if currentStart < ex.upperBound {
                    currentStart = ex.upperBound
                }
            }
            if currentStart < fullRange.upperBound {
                allowedRanges.append(currentStart..<fullRange.upperBound)
            }
            return allowedRanges
        }
        
        mutating func defaultVisit(_ markup: any Markup) {
            descendInto(markup)
        }
        
        mutating func visitCodeBlock(_ codeBlock: CodeBlock) {
            guard let range = codeBlock.range else { return }
            resolvableExcludedRanges.append(range)
        }

        mutating func visitInlineCode(_ inlineCode: InlineCode) {
            guard let range = inlineCode.range else { return }
            resolvableExcludedRanges.append(range)
        }

        mutating func visitLink(_ link: Link) {
            resolvableExcludedRanges.append(link)
            descendInto(link)
        }

        mutating func visitImage(_ image: Image) {
            guard let range = image.range else { return }
            resolvableExcludedRanges.append(range)
        }
    }
}
