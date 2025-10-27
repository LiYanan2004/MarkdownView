import SwiftUI
import Markdown

/// A view that produces content from the headings found in a Markdown document.
///
/// Pass the same ``MarkdownContent`` that drives your ``MarkdownView`` so the
/// table of contents stays in sync. The easiest way to do this is to wrap both
/// views in a ``MarkdownReader``.
public struct MarkdownTableOfContent<Content: View>: View {
    @ObservedObject private var content: MarkdownContent
    private var contents: (_ headings: [MarkdownHeading]) -> Content

    public init(
        _ content: MarkdownContent,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        self.content = content
        self.contents = contents
    }
    
    @_disfavoredOverload
    public init(
        _ content: URL,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        self.content = .init(content)
        self.contents = contents
    }
    
    @_disfavoredOverload
    public init(
        _ content: String,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        self.content = .init(content)
        self.contents = contents
    }
    
    private var headings: [MarkdownHeading] {
        var toc = TableOfContentVisitor()
        toc.visit(
            content.store.documents.first ?? content.document()
        )
        return toc.headings
    }
    
    public var body: some View {
        contents(headings)
    }
}

// MARK: - Auxiliary

fileprivate struct TableOfContentVisitor: MarkupWalker {
    private(set) var headings: [MarkdownHeading] = []
    
    mutating func visitHeading(_ heading: Markdown.Heading) {
        headings.append(MarkdownHeading(heading: heading))
        descendInto(heading)
    }
}
