//
//  MarkdownRenderingOutput.swift
//  MarkdownView
//

@dynamicMemberLookup
struct MarkdownRenderingOutput: Sendable {
    let mathContext: MarkdownMathContext?
    let parseResult: MarkdownDocumentParser.ParseResult

    subscript<T>(dynamicMember keyPath: KeyPath<MarkdownDocumentParser.ParseResult, T>) -> T {
        parseResult[keyPath: keyPath]
    }
}
