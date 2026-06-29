import Markdown

struct MarkdownTextSemanticList {
    enum Kind {
        case ordered
        case unordered
    }

    var kind: Kind
    var depth: Int
    var sourceMarkup: any ListItemContainer
    var items: [MarkdownTextSemanticListItem]
}

struct MarkdownTextSemanticListItem {
    var marker: MarkdownTextSemanticListMarker?
    var sourceMarkup: ListItem
    var leadingChildren: [any Markup]
    var trailingBlocks: [any Markup]

    init(
        marker: MarkdownTextSemanticListMarker?,
        sourceMarkup: ListItem
    ) {
        let children = Array(sourceMarkup.children)

        if let paragraph = children.first as? Paragraph {
            self.leadingChildren = Array(paragraph.children)
            self.trailingBlocks = Array(children.dropFirst())
        } else {
            self.leadingChildren = []
            self.trailingBlocks = children
        }

        self.marker = marker
        self.sourceMarkup = sourceMarkup
    }
}

enum MarkdownTextSemanticListMarker {
    case checkbox(Checkbox)
    case text(value: String, monospaced: Bool)
}
