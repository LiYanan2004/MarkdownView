import SwiftUI
import Markdown

/// A view that produces content from the headings found in a Markdown document.
///
/// Pass the same ``MarkdownContent`` that drives your ``MarkdownView`` so the
/// table of contents stays in sync and no extra parsing is performed. The
/// easiest way to do this is to wrap both views in a ``MarkdownReader``.
public struct MarkdownTableOfContent<Content: View>: View {
    private var markdownContent: MarkdownContent
    private var contents: (_ headings: [MarkdownHeading]) -> Content

    public init(
        _ markdownContent: MarkdownContent,
        @ViewBuilder contents: @escaping ([MarkdownHeading]) -> Content
    ) {
        self.markdownContent = markdownContent
        self.contents = contents
    }
    
    private var headings: [MarkdownHeading] {
        var toc = TableOfContentVisitor()
        toc.visit(
            markdownContent.store.documents.first ?? markdownContent.parse()
        )
        return toc.headings
    }
    
    public var body: some View {
        contents(headings)
    }
}

extension MarkdownTableOfContent {
    /// A representation of a markdown heading.
    public struct MarkdownHeading: Hashable, Sendable {
        private var heading: Markdown.Heading
        
        /// Heading level, starting from 1.
        public var level: Int {
            heading.level
        }
        /// The range of the heading in the raw Markdown.
        ///
        /// The range originates from `swift-markdown`’s parsing result. It is
        /// present when the Markdown source carried location information (for
        /// example when it was loaded from a file URL).
        public var range: SourceRange? {
            heading.range
        }
        /// The content text of the heading.
        public var plainText: String {
            heading.plainText
        }
        
        init(heading: Heading) {
            self.heading = heading
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(level)
            hasher.combine(range)
            hasher.combine(plainText)
        }
        
        public static func == (lhs: MarkdownHeading, rhs: MarkdownHeading) -> Bool {
            lhs.heading.isIdentical(to: rhs.heading)
        }
    }
    
    struct TableOfContentVisitor: MarkupWalker {
        private(set) var headings: [MarkdownHeading] = []
        
        mutating func visitHeading(_ heading: Markdown.Heading) {
            headings.append(MarkdownHeading(heading: heading))
            descendInto(heading)
        }
    }
}
