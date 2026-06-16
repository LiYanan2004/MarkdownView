//
//  InlineMathOrText.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI
import MarkdownMathPlugin
import MarkdownPresentation

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
    func makeBody(configuration: MarkdownRendererConfiguration) -> MarkdownNodeView {
        #if canImport(LaTeXSwiftUI)
        let mathSegments = self.mathSegments(configuration: configuration)

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

#if canImport(LaTeXSwiftUI)
fileprivate extension InlineMathOrText {
    struct MathSegment {
        var range: Range<String.Index>
        var latexText: String
    }

    func mathSegments(configuration: MarkdownRendererConfiguration) -> [MathSegment] {
        let placeholderSegments = inlinePlaceholderSegments(configuration: configuration)
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

    func inlinePlaceholderSegments(configuration: MarkdownRendererConfiguration) -> [MathSegment] {
        guard let inlineMathStorage = configuration.math.inlineMathStorage else {
            return []
        }

        var mathSegments: [MathSegment] = []
        for (identifier, latexText) in inlineMathStorage {
            let placeholder = MDMathPreprocessor.inlinePlaceholder(for: identifier)
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

#if canImport(LaTeXSwiftUI)
struct InlineMath: View {
    var latexText: String
    @Environment(\.markdownFontGroup.inlineMath) private var font

    var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            ViewThatFits(in: .horizontal) {
                LaTeX(latexText)
                    .renderingStyle(.wait)
                    .blockMode(.alwaysInline)
                    .font(font)
                ScrollView(.horizontal) {
                    LaTeX(latexText)
                        .renderingStyle(.wait)
                        .blockMode(.alwaysInline)
                        .font(font)
                }
            }
        } else {
            LaTeX(latexText)
                .renderingStyle(.wait)
                .blockMode(.alwaysInline)
                .font(font)
        }
    }
}
#endif
