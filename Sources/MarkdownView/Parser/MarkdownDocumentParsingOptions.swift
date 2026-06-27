//
//  MarkdownDocumentParsingOptions.swift
//  MarkdownView
//

import Markdown

struct MarkdownDocumentParsingOptions: OptionSet, Sendable, Hashable {
    let rawValue: UInt8
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
    
    static let rendersMath = MarkdownDocumentParsingOptions(rawValue: 1 << 0)
    static let parsesBlockDirectives = MarkdownDocumentParsingOptions(rawValue: 1 << 1)
}

extension MarkdownDocumentParsingOptions {
    var markdownParseOptions: ParseOptions {
        var markdownParseOptions = ParseOptions()

        if contains(.parsesBlockDirectives) {
            markdownParseOptions.insert(.parseBlockDirectives)
        }

        return markdownParseOptions
    }
}
