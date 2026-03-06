import SwiftUI
import Markdown

/// A view that produces content from the headings found in a Markdown document.
///
/// Pass the same ``MarkdownContent`` that drives your ``MarkdownView`` so the
/// table of contents stays in sync. The easiest way to do this is to wrap both
/// views in a ``MarkdownReader``.
public struct MarkdownTableOfContent<Content: View>: View {
    @StateObject private var ownedContent: MarkdownContent
    @ObservedObject private var externalContent: MarkdownContent
    private var usesExternalContent: Bool
    private var contents: (_ headings: [MarkdownHeading]) -> Content

    private var content: MarkdownContent {
        usesExternalContent ? externalContent : ownedContent
    }

    public init(
        _ content: MarkdownContent,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        _ownedContent = StateObject(wrappedValue: content)
        _externalContent = ObservedObject(wrappedValue: content)
        usesExternalContent = true
        self.contents = contents
    }

    @_disfavoredOverload
    public init(
        _ content: URL,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        let mc = MarkdownContent(content)
        _ownedContent = StateObject(wrappedValue: mc)
        _externalContent = ObservedObject(wrappedValue: mc)
        usesExternalContent = false
        self.contents = contents
    }

    @_disfavoredOverload
    public init(
        _ content: String,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        let mc = MarkdownContent(content)
        _ownedContent = StateObject(wrappedValue: mc)
        _externalContent = ObservedObject(wrappedValue: mc)
        usesExternalContent = false
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
