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

            switch mathSegment.kind {
            case .inline:
                nodeViews.append(MarkdownNodeView {
                    InlineMath(latexText: mathSegment.latexText)
                })
            case .display:
                if let identifier = mathSegment.identifier {
                    nodeViews.append(MarkdownNodeView {
                        MarkdownDisplayMathView(mathIdentifier: identifier)
                            .id(identifier)
                    })
                }
            }

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
        var kind: MarkdownMathPreprocessor.PlaceholderKind
        var range: Range<String.Index>
        var latexText: String
        var identifier: UUID?
    }

    func mathSegments(mathContext: MarkdownMathContext?) -> [MathSegment] {
        let placeholderSegments = mathPlaceholderSegments(mathContext: mathContext)
        let parsedSegments = MathParser(text: text)
            .mathRepresentations
            .lazy
            .map {
                MathSegment(
                    kind: .inline,
                    range: $0.range,
                    latexText: String(text[$0.range]),
                    identifier: nil
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

    func mathPlaceholderSegments(mathContext: MarkdownMathContext?) -> [MathSegment] {
        MarkdownMathPreprocessor.placeholderSegments(in: text).compactMap { placeholderSegment in
            switch placeholderSegment.match.kind {
            case .inline:
                guard let latexText = mathContext?.inlineMathStorage[placeholderSegment.match.identifier] else {
                    return nil
                }

                return MathSegment(
                    kind: .inline,
                    range: placeholderSegment.range,
                    latexText: latexText,
                    identifier: placeholderSegment.match.identifier
                )
            case .display:
                guard let latexText = mathContext?.displayMathStorage[placeholderSegment.match.identifier] else {
                    return nil
                }

                return MathSegment(
                    kind: .display,
                    range: placeholderSegment.range,
                    latexText: latexText,
                    identifier: placeholderSegment.match.identifier
                )
            }
        }
    }
}
#endif
