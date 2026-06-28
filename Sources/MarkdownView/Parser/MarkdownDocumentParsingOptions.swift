//
//  MarkdownDocumentParsingOptions.swift
//  MarkdownView
//

import Markdown

public struct MarkdownDocumentParsingOptions: OptionSet, Sendable, Hashable {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static public let rendersMath = MarkdownDocumentParsingOptions(rawValue: 1 << 0)
    static public let parsesBlockDirectives = MarkdownDocumentParsingOptions(rawValue: 1 << 1)
}

extension MarkdownDocumentParsingOptions {
    init(
        mathContext: MarkdownMathContext?,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        var options = MarkdownDocumentParsingOptions()
        
        if mathContext != nil {
            options.insert(.rendersMath)
        }
        if elementRenderers.contains(where: { $0.blockDirective != nil }) {
            options.insert(.parsesBlockDirectives)
        }
        
        self = options
    }
}

extension MarkdownDocumentParsingOptions {
    public var markdownParseOptions: ParseOptions {
        var markdownParseOptions = ParseOptions()

        if contains(.parsesBlockDirectives) {
            markdownParseOptions.insert(.parseBlockDirectives)
        }

        return markdownParseOptions
    }
}
