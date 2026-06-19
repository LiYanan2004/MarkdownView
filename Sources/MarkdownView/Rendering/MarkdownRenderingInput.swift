//
//  MarkdownRenderingInput.swift
//  MarkdownView
//

import Markdown

struct MarkdownRenderingInput {
    let content: MarkdownContent
    let configuration: MarkdownRendererConfiguration
    let parseOptions: ParseOptions

    init(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        var parseOptions = ParseOptions()
        if configuration.math.shouldRender
            || elementRenderers.contains(where: { $0.blockDirective != nil }) {
            parseOptions.insert(.parseBlockDirectives)
        }
        self.parseOptions = parseOptions

        guard configuration.math.shouldRender, MarkdownRenderingInput.supportsMathRendering else {
            self.content = content
            self.configuration = configuration
            return
        }

        let preprocessingResult = MDMathPreprocessor()
            .preprocessingResult(for: content.raw.text)
        self.content = MarkdownContent(raw: .plainText(preprocessingResult.markdown))
        self.configuration = configuration
            .with(\.math.context, preprocessingResult.context)
    }

    private static var supportsMathRendering: Bool {
        #if canImport(LaTeXSwiftUI)
        true
        #else
        false
        #endif
    }
}
