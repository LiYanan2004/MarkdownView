import SwiftUI
import Markdown

public struct MarkdownTableOfContent<Content: View>: View {
    var markdownContent: ParsedMarkdownContent
    private var viewContent: (_ headings: [MarkdownHeading]) -> Content

    public init(
        _ markdownContent: ParsedMarkdownContent,
        @ViewBuilder viewContent: @escaping ([MarkdownHeading]) -> Content
    ) {
        self.markdownContent = markdownContent
        self.viewContent = viewContent
    }
    
    private var headings: [MarkdownHeading] {
        var toc = TableOfContentVisitor()
        toc.visit(markdownContent.document)
        return toc.headings
    }
    
    public var body: some View {
        viewContent(headings)
    }
}

extension MarkdownTableOfContent {
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

