#if canImport(RichText) && ENABLE_MATH_RENDERING

import Foundation
import RichText
import SwiftUI
import Markdown

extension MarkdownTextConverter {
    func mathPlaceholderTextContent(
        text: String,
        mathContext: MarkdownMathContext,
        sourceMarkup: Markdown.Text
    ) -> TextContent {
        var textContent = TextContent([])
        var searchRange = text.startIndex..<text.endIndex
        var inlineMathOccurrence = 0
        var displayMathOccurrence = 0

        for placeholderSegment in MarkdownMathPreprocessor.placeholderSegments(in: text) {
            guard placeholderSegment.range.lowerBound >= searchRange.lowerBound else {
                continue
            }

            if searchRange.lowerBound < placeholderSegment.range.lowerBound {
                textContent += TextContent(
                    .string(String(text[searchRange.lowerBound..<placeholderSegment.range.lowerBound]))
                )
            }

            switch placeholderSegment.match.kind {
            case .inline:
                guard let latexText = mathContext.inlineMathStorage[placeholderSegment.match.identifier] else {
                    textContent += TextContent(.string(String(text[placeholderSegment.range])))
                    searchRange = placeholderSegment.range.upperBound..<text.endIndex
                    continue
                }

                textContent += TextContent {
                    InlineView(
                        id: MarkdownTextInlineViewIdentifier(
                            markup: sourceMarkup,
                            role: .math(kind: .inline, occurrence: inlineMathOccurrence)
                        ),
                        replacement: AttributedString(latexText)
                    ) {
                        InlineMath(latexText: latexText)
                    }
                }
                inlineMathOccurrence += 1
            case .display:
                let identifier = placeholderSegment.match.identifier
                guard mathContext.displayMathStorage[identifier] != nil else {
                    textContent += TextContent(.string(String(text[placeholderSegment.range])))
                    searchRange = placeholderSegment.range.upperBound..<text.endIndex
                    continue
                }

                textContent += MarkdownTextEmbeddingViewFactory.makeTextContent(
                    id: MarkdownTextInlineViewIdentifier(
                        markup: sourceMarkup,
                        role: .math(kind: .display, occurrence: displayMathOccurrence)
                    ),
                    replacement: nil,
                    componentSpacing: configuration.componentSpacing,
                    sizing: .fittingLineFragment
                ) {
                    MarkdownDisplayMathView(mathIdentifier: identifier)
                        .id(identifier)
                }
                displayMathOccurrence += 1
            }

            searchRange = placeholderSegment.range.upperBound..<text.endIndex
        }

        if searchRange.lowerBound < text.endIndex {
            textContent += TextContent(.string(String(text[searchRange])))
        }

        return textContent
    }
}

#endif
