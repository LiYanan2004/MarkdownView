//
//  InlineMathOrText.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI

@preconcurrency
@MainActor
struct InlineMathOrText {
    var text: String

    @preconcurrency
    @MainActor
    func makeBody(mathContext: MarkdownMathContext?) -> MarkdownNodeView {
        #if ENABLE_MATH_RENDERING
        let mathSegments = self.mathSegments(mathContext: mathContext)

        guard !mathSegments.isEmpty else {
            return MarkdownNodeView(text)
        }

        var nodeViews: [MarkdownNodeView] = []
        var processingIndex = text.startIndex

        for mathSegment in mathSegments {
            if processingIndex < mathSegment.range.lowerBound {
                let normalText = String(text[processingIndex..<mathSegment.range.lowerBound])
                nodeViews.append(MarkdownNodeView(normalText))
            }

            nodeViews.append(
                MarkdownNodeView {
                    InlineMath(latexText: mathSegment.latexText)
                }
            )

            processingIndex = mathSegment.range.upperBound
        }

        if processingIndex < text.endIndex {
            let remainingText = String(text[processingIndex..<text.endIndex])
            nodeViews.append(MarkdownNodeView(remainingText))
        }

        return MarkdownNodeView(nodeViews)
        #else
        return MarkdownNodeView(text)
        #endif
    }
}

#if ENABLE_MATH_RENDERING
fileprivate extension InlineMathOrText {
    struct MathSegment {
        var range: Range<String.Index>
        var latexText: String
    }

    func mathSegments(mathContext: MarkdownMathContext?) -> [MathSegment] {
        let placeholderSegments = inlinePlaceholderSegments(mathContext: mathContext)
        let parsedSegments = MathParser(text: text)
            .mathRepresentations
            .lazy
            .map {
                MathSegment(
                    range: $0.range,
                    latexText: String(text[$0.range])
                )
            }
            .filter { parsedSegment in
                !placeholderSegments.contains { placeholderSegment in
                    parsedSegment.range.overlaps(placeholderSegment.range)
                }
            }

        return (placeholderSegments + parsedSegments)
            .sorted { $0.range.lowerBound < $1.range.lowerBound }
    }

    func inlinePlaceholderSegments(mathContext: MarkdownMathContext?) -> [MathSegment] {
        guard let inlineMathStorage = mathContext?.inlineMathStorage else {
            return []
        }

        var mathSegments: [MathSegment] = []
        for (identifier, latexText) in inlineMathStorage {
            let placeholder = MarkdownMathPreprocessor.inlinePlaceholder(for: identifier)
            var searchRange = text.startIndex..<text.endIndex

            while let placeholderRange = text.range(of: placeholder, range: searchRange) {
                mathSegments.append(
                    MathSegment(
                        range: placeholderRange,
                        latexText: latexText
                    )
                )
                searchRange = placeholderRange.upperBound..<text.endIndex
            }
        }

        return mathSegments
    }
}
#endif
