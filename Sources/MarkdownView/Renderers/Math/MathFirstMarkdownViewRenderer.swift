//
//  MathFirstMarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

struct MathFirstMarkdownViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        var configuration = configuration
        var rawText = (try? content.markdown) ?? ""
        
        var extractor = ParsingRangesExtractor()
        extractor.visit(content.document())
        for range in extractor.parsableRanges(in: rawText) {
            let segment = rawText[range]
            let segmentParser = MathParser(text: segment)
            for math in segmentParser.mathRepresentations.reversed() where !math.kind.inline {
                let mathIdentifier = configuration.math.appendDisplayMath(
                    rawText[math.range]
                )
                rawText.replaceSubrange(
                    math.range,
                    with: "@math(uuid:\(mathIdentifier))"
                )
            }
        }
        
        return CmarkFirstMarkdownViewRenderer().makeBody(
            content: MarkdownContent(.plainText(rawText)),
            configuration: configuration
        )
    }
}

// MARK: - Auxiliary

fileprivate extension MathFirstMarkdownViewRenderer {
    struct ParsingRangesExtractor: MarkupWalker {
        private var excludedRanges: [Range<SourceLocation>] = []
        
        func parsableRanges(in text: String) -> [Range<String.Index>] {
            var allowedRanges: [Range<String.Index>] = []
            let excludedRanges = self.excludedRanges.map {
                ($0.lowerBound.index(in: text)..<$0.upperBound.index(in: text))
            }

            let fullRange = text.startIndex..<text.endIndex
            let sortedExcluded = excludedRanges.sorted { $0.lowerBound < $1.lowerBound }
            var currentStart = fullRange.lowerBound
            
            for ex in sortedExcluded {
                if currentStart < ex.lowerBound {
                    allowedRanges.append(currentStart..<ex.lowerBound)
                }
                currentStart = ex.upperBound
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
            self.excludedRanges.append(range)
        }
    }
}

fileprivate extension SourceLocation {
    func index(in string: String) -> String.Index {
        var idx = string.startIndex
        var currentLine = 1
        while currentLine < self.line && idx < string.endIndex {
            if string[idx] == "\n" {
                currentLine += 1
            }
            idx = string.index(after: idx)
        }
        guard let utf8LineStart = idx.samePosition(in: string.utf8) else {
            return string.endIndex
        }
        let byteOffset = self.column - 1
        let targetUtf8Index = string.utf8.index(utf8LineStart, offsetBy: byteOffset, limitedBy: string.utf8.endIndex) ?? string.utf8.endIndex
        return targetUtf8Index.samePosition(in: string) ?? string.endIndex
    }
}
