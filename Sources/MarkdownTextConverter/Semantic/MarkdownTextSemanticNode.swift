import Markdown

enum MarkdownTextSemanticNode {
    case passthrough(any Markup)
    case list(MarkdownTextSemanticList)
    case attachment(MarkdownTextAttachment)
}
