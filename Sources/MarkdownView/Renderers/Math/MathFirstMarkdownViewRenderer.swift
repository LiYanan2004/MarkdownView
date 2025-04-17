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
        var rawText = content.raw.text
        
        var walker = MathRangeWalker()
        walker.visit(content.document)
        let parsingRanges = walker.parsingRanges(text: rawText)
        for range in parsingRanges {
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
        
        let _content = MarkdownContent(raw: .plainText(rawText))
        return CmarkFirstMarkdownViewRenderer()
            .makeBody(content: _content, configuration: configuration)
    }
}

extension MathFirstMarkdownViewRenderer {
    struct MathRangeWalker: MarkupWalker {
        private var excludedRanges: [Range<SourceLocation>] = []
        
        func parsingRanges(text: String) -> [Range<String.Index>] {
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

extension SourceLocation {
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
