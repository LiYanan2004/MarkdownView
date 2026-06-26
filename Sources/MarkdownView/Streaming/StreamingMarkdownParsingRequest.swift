//
//  StreamingMarkdownParsingRequest.swift
//  MarkdownView
//

struct StreamingMarkdownParsingRequest: Hashable, Sendable {
    let sourceText: String
    let configuration: MarkdownRendererConfiguration
    let requiresBlockDirectiveParsing: Bool
}
