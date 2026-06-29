#if canImport(RichText) && ENABLE_MATH_RENDERING

import Foundation
import RichText
import SwiftUI
import Markdown

extension MarkdownTextConverter {
    func inlineMathTextContent(
        text: String,
        inlineMathStorage: [UUID: String],
        sourceMarkup: Markdown.Text
    ) -> TextContent {
        var textContent = TextContent([])
        var searchRange = text.startIndex..<text.endIndex
        var inlineMathOccurrence = 0

        while let placeholderMatch = firstInlineMathPlaceholderMatch(
            in: text,
            range: searchRange,
            inlineMathStorage: inlineMathStorage
        ) {
            if searchRange.lowerBound < placeholderMatch.range.lowerBound {
                textContent += TextContent(
                    .string(String(text[searchRange.lowerBound..<placeholderMatch.range.lowerBound]))
                )
            }

            textContent += TextContent {
                InlineView(
                    id: MarkdownTextInlineViewIdentifier(
                        markup: sourceMarkup,
                        role: .inlineMath(occurrence: inlineMathOccurrence)
                    ),
                    replacement: AttributedString(placeholderMatch.latexText)
                ) {
                    InlineMath(latexText: placeholderMatch.latexText)
                }
            }
            inlineMathOccurrence += 1
            searchRange = placeholderMatch.range.upperBound..<text.endIndex
        }

        if searchRange.lowerBound < text.endIndex {
            textContent += TextContent(.string(String(text[searchRange])))
        }

        return textContent
    }
}

private extension MarkdownTextConverter {
    func firstInlineMathPlaceholderMatch(
        in text: String,
        range: Range<String.Index>,
        inlineMathStorage: [UUID: String]
    ) -> InlineMathPlaceholderMatch? {
        inlineMathStorage
            .compactMap { identifier, latexText -> InlineMathPlaceholderMatch? in
                let placeholder = MarkdownMathPreprocessor.inlinePlaceholder(for: identifier)
                guard let range = text.range(of: placeholder, range: range) else {
                    return nil
                }

                return InlineMathPlaceholderMatch(range: range, latexText: latexText)
            }
            .min { $0.range.lowerBound < $1.range.lowerBound }
    }
}

private struct InlineMathPlaceholderMatch {
    var range: Range<String.Index>
    var latexText: String
}

#endif
