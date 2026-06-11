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
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        let (preprocessedContent, preprocessedConfiguration) = preprocessedMathContent(
            content: content,
            configuration: configuration
        )
        return CmarkFirstMarkdownViewRenderer()
            .makeBody(
                content: preprocessedContent,
                configuration: preprocessedConfiguration,
                elementRenderers: elementRenderers
            )
    }
}

#if canImport(RichText)

@available(iOS 26.0, macOS 26.0, *)
struct MathFirstTextViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        let (preprocessedContent, preprocessedConfiguration) = preprocessedMathContent(
            content: content,
            configuration: configuration
        )
        TextViewViewRenderer().makeBody(
            content: preprocessedContent,
            configuration: preprocessedConfiguration,
            elementRenderers: elementRenderers
        )
    }
}

#endif

// MARK: - Auxiliary

private func preprocessedMathContent(
    content: MarkdownContent,
    configuration: MarkdownRendererConfiguration
) -> (content: MarkdownContent, configuration: MarkdownRendererConfiguration) {
    var configuration = configuration
    let rawText = (try? content.markdown) ?? ""

    var mathRangesResolver = MathParsableRangesResolver()
    mathRangesResolver.visit(content.document(options: ParseOptions().union(.parseBlockDirectives)))

    #if canImport(LaTeXSwiftUI)
    let includeInlineMath = true
    #else
    let includeInlineMath = false
    #endif

    let preprocessedMath = MathPlaceholderPreprocessor.process(
        rawText,
        parsableRanges: mathRangesResolver.resolve(in: rawText),
        includeInlineMath: includeInlineMath
    )
    configuration.math.displayMathStorage = preprocessedMath.displayMathStorage
    configuration.math.inlineMathStorage = preprocessedMath.inlineMathStorage

    return (
        MarkdownContent(.plainText(preprocessedMath.markdown)),
        configuration
    )
}
