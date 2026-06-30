//
//  MarkdownTextSemanticBuilder.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/15.
//

import Markdown

struct MarkdownTextSemanticBuilder: MarkupVisitor {
    var configuration: MarkdownRendererConfiguration

    init(configuration: MarkdownRendererConfiguration) {
        self.configuration = configuration
    }

    func makeNodes(for markup: any Markup) -> [MarkdownTextSemanticNode] {
        if let document = markup as? Markdown.Document {
            return makeNodes(descendingInto: document)
        }

        return [makeNode(for: markup)]
    }

    func makeNodes(descendingInto markup: any Markup) -> [MarkdownTextSemanticNode] {
        Array(markup.children).map(makeNode(for:))
    }

    func defaultVisit(_ markup: Markup) -> MarkdownTextSemanticNode {
        .passthrough(markup)
    }

    func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownTextSemanticNode {
        .attachment(MarkdownTextAttachment(blockQuote))
    }

    func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownTextSemanticNode {
        .attachment(MarkdownTextAttachment(blockDirective))
    }

    func visitImage(_ image: Markdown.Image) -> MarkdownTextSemanticNode {
        .attachment(MarkdownTextAttachment(image))
    }

    func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownTextSemanticNode {
        .attachment(MarkdownTextAttachment(codeBlock))
    }

    func visitHTMLBlock(_ htmlBlock: HTMLBlock) -> MarkdownTextSemanticNode {
        .attachment(MarkdownTextAttachment(htmlBlock))
    }

    func visitOrderedList(_ orderedList: OrderedList) -> MarkdownTextSemanticNode {
        .list(
            MarkdownTextSemanticList(
                kind: .ordered,
                depth: orderedList.listDepth,
                sourceMarkup: orderedList,
                items: makeListItems(from: orderedList)
            )
        )
    }

    func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownTextSemanticNode {
        .list(
            MarkdownTextSemanticList(
                kind: .unordered,
                depth: unorderedList.listDepth,
                sourceMarkup: unorderedList,
                items: makeListItems(from: unorderedList)
            )
        )
    }

    func visitListItem(_ listItem: ListItem) -> MarkdownTextSemanticNode {
        .passthrough(listItem)
    }

    func visitTable(_ table: Markdown.Table) -> MarkdownTextSemanticNode {
        .attachment(MarkdownTextAttachment(table))
    }
}

private extension MarkdownTextSemanticBuilder {
    func makeNode(for markup: any Markup) -> MarkdownTextSemanticNode {
        var semanticBuilder = self
        return semanticBuilder.visit(markup)
    }

    func makeListItems(
        from listItemContainer: some ListItemContainer
    ) -> [MarkdownTextSemanticListItem] {
        listItemContainer.listItems.map(makeListItem(from:))
    }

    func makeListItem(from listItem: ListItem) -> MarkdownTextSemanticListItem {
        MarkdownTextSemanticListItem(
            marker: makeListMarker(for: listItem),
            sourceMarkup: listItem
        )
    }

    func makeListMarker(for listItem: ListItem) -> MarkdownTextSemanticListMarker? {
        if let checkbox = listItem.checkbox {
            return .checkbox(checkbox)
        }

        if let unorderedList = listItem.parent as? UnorderedList {
            let marker = configuration.listConfiguration.unorderedListMarker
            return .text(
                value: marker.marker(listDepth: unorderedList.listDepth),
                monospaced: marker.monospaced
            )
        }

        if let orderedList = listItem.parent as? OrderedList {
            let marker = configuration.listConfiguration.orderedListMarker
            return .text(
                value: marker.marker(
                    at: listItem.indexInParent,
                    listDepth: orderedList.listDepth
                ),
                monospaced: marker.monospaced
            )
        }

        return nil
    }
}
