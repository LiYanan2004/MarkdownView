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
        var configuration = configuration
        let rawText = content.raw.text

        var extractor = ParsingRangesExtractor()
        extractor.visit(content.parse(options: ParseOptions().union(.parseBlockDirectives)))

        #if canImport(LaTeXSwiftUI)
        let includeInlineMath = true
        #else
        let includeInlineMath = false
        #endif

        let preprocessedMath = MathPlaceholderPreprocessor()
            .process(
                rawText,
                parsableRanges: extractor.parsableRanges(in: rawText),
                includeInlineMath: includeInlineMath
            )
        configuration.math.displayMathStorage = preprocessedMath.displayMathStorage
        configuration.math.inlineMathStorage = preprocessedMath.inlineMathStorage

        let _content = MarkdownContent(raw: .plainText(preprocessedMath.markdown))
        return CmarkFirstMarkdownViewRenderer()
            .makeBody(content: _content, configuration: configuration, elementRenderers: elementRenderers)
    }
}
