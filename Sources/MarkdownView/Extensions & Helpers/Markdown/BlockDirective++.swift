import Markdown

extension BlockDirective {
    var wrappedMarkdown: String {
        // Format from a new root to exclude the directive's indentation.
        Document(blockChildren).format()
    }
}
