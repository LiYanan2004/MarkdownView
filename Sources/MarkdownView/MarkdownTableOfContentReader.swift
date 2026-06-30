//
//  MarkdownTableOfContentReader.swift
//  MarkdownView
//

import SwiftUI
import Markdown

/// Reads headings from a parsed markdown result or document and builds a custom table of contents view.
///
/// Use ``MarkdownReader`` when ``MarkdownView`` and ``MarkdownTableOfContentReader`` should share the same parse result instance.
///
/// ``MarkdownTableOfContentReader`` conforms to `Equatable`, so you can add `.equatable()` view modifier when the content builder depends only on the provided `Markdown.Document` and the derived headings, so SwiftUI can skip recomputing the view body when document identity stays the same.
public struct MarkdownTableOfContentReader<Content: View>: View, @MainActor Equatable {
    private var document: Markdown.Document
    private var content: (_ headings: [Markdown.Heading]) -> Content

    /// Creates a table-of-contents reader from a parsed markdown document.
    ///
    /// - Parameters:
    ///   - document: The parsed markdown document to inspect.
    ///   - content: A view builder that receives the headings extracted from the document.
    public init(
        _ document: Markdown.Document,
        @ViewBuilder content: @escaping ([Markdown.Heading]) -> Content
    ) {
        self.document = document
        self.content = content
    }
    
    /// Creates a table-of-contents reader from a parsed markdown result.
    ///
    /// - Parameters:
    ///   - parseResult: The parsed markdown result to inspect.
    ///   - content: A view builder that receives the headings extracted from the result document.
    public init(
        _ parseResult: MarkdownParseResult,
        @ViewBuilder content: @escaping ([Markdown.Heading]) -> Content
    ) {
        self.init(parseResult.document, content: content)
    }
    
    /// Creates a table-of-contents reader from a markdown string.
    ///
    /// - Parameters:
    ///   - string: The markdown source to parse.
    ///   - content: A view builder that receives the headings extracted from the parsed document.
    public init(
        _ string: String,
        @ViewBuilder content: @escaping ([Markdown.Heading]) -> Content
    ) {
        self.init(Markdown.Document(parsing: string), content: content)
    }
    
    private var headings: [Heading] {
        var collector = MarkdownHeadingCollector()
        collector.visit(document)
        return collector.headings
    }
    
    public var body: some View {
        content(headings)
    }
    
    public static func == (
        lhs: MarkdownTableOfContentReader<Content>,
        rhs: MarkdownTableOfContentReader<Content>
    ) -> Bool {
        lhs.document.isIdentical(to: rhs.document)
    }
}

/// Deprecated alias for ``MarkdownTableOfContentReader``.
@available(*, deprecated, renamed: "MarkdownTableOfContentReader")
public typealias MarkdownTableOfContent<Content: View> = MarkdownTableOfContentReader<Content>

fileprivate struct MarkdownHeadingCollector: MarkupWalker {
    private(set) var headings: [Markdown.Heading] = []
    
    mutating func visitHeading(_ heading: Markdown.Heading) {
        headings.append(heading)
    }
}
