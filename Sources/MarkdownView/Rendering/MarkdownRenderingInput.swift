//
//  MarkdownRenderingInput.swift
//  MarkdownView
//

import Markdown

enum MarkdownRenderingSource {
    case rawText(String)
    case document(Markdown.Document)
}

struct MarkdownRenderingInput: Sendable {
    let document: Markdown.Document
    let configuration: MarkdownRendererConfiguration

    init(
        document: Markdown.Document,
        configuration: MarkdownRendererConfiguration
    ) {
        self.document = document
        self.configuration = configuration
    }

    init(
        source: MarkdownRenderingSource,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        self.init(
            source: source,
            configuration: configuration,
            requiresBlockDirectiveParsing: elementRenderers.contains(where: { $0.blockDirective != nil })
        )
    }

    init(
        source: MarkdownRenderingSource,
        configuration: MarkdownRendererConfiguration,
        requiresBlockDirectiveParsing: Bool
    ) {
        let parseOptions = Self.parseOptions(
            requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
        )

        switch source {
        case .document(let document):
            self.document = document
            self.configuration = configuration

        case .rawText(let text):
            if configuration.math.shouldRender, Self.supportsMathRendering {
                let preprocessingResult = MarkdownMathPreprocessor()
                    .preprocessingResult(
                        for: text,
                        requiresBlockDirectiveParsing: requiresBlockDirectiveParsing
                    )
                self.document = Markdown.Document(
                    parsing: preprocessingResult.markdown,
                    options: parseOptions
                )
                self.configuration = configuration
                    .with(\.math.context, preprocessingResult.context)
            } else {
                self.document = Markdown.Document(
                    parsing: text,
                    options: parseOptions
                )
                self.configuration = configuration
            }

        }
    }

    static func parseOptions(requiresBlockDirectiveParsing: Bool) -> ParseOptions {
        var parseOptions = ParseOptions()
        if requiresBlockDirectiveParsing {
            parseOptions.insert(.parseBlockDirectives)
        }
        return parseOptions
    }

    private static var supportsMathRendering: Bool {
        #if canImport(SwiftMath)
        true
        #else
        false
        #endif
    }
}
