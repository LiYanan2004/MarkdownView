//
//  MarkdownDocumentParsingOptions.swift
//  MarkdownView
//

import Markdown

/// Options that control markdown parsing before rendering.
public struct MarkdownDocumentParsingOptions: OptionSet, Sendable, Hashable {
    /// The raw value that stores the selected parsing options.
    public let rawValue: UInt8
    
    /// Creates parsing options from a raw value.
    ///
    /// - Parameter rawValue: The raw option value.
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    /// Parses LaTeX math expressions before rendering.
    static public let rendersMath = MarkdownDocumentParsingOptions(rawValue: 1 << 0)

    /// Parses block directives before rendering.
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
    /// The `swift-markdown` parse options represented by this value.
    package var markdownParseOptions: ParseOptions {
        var markdownParseOptions = ParseOptions()

        if contains(.parsesBlockDirectives) {
            markdownParseOptions.insert(.parseBlockDirectives)
        }

        return markdownParseOptions
    }
}
