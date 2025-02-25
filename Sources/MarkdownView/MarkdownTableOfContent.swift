import SwiftUI
import Markdown

/// A customized view that defines its content as a function of a set of headings
public struct MarkdownTableOfContent<Content: View>: View {
    var markdownContent: MarkdownContent
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
        toc.visit(markdownContent.document)
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

