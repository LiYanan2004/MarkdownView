//
//  MarkdownParseRequest.swift
//  MarkdownView
//

import Foundation

struct MarkdownParseRequest: Sendable, Hashable {
    let sourceText: String
    let parsingOptions: MarkdownDocumentParsingOptions

    init(
        sourceText: String,
        parsingOptions: MarkdownDocumentParsingOptions
    ) {
        self.sourceText = sourceText
        self.parsingOptions = parsingOptions
    }

    init(
        sourceText: String,
        mathContext: MarkdownMathContext?,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        var parsingOptions: MarkdownDocumentParsingOptions = []
        if mathContext != nil {
            parsingOptions.insert(.rendersMath)
        }
        if elementRenderers.contains(where: { $0.blockDirective != nil }) {
            parsingOptions.insert(.parsesBlockDirectives)
        }
        
        self.init(
            sourceText: sourceText,
            parsingOptions: parsingOptions
        )
    }
}
