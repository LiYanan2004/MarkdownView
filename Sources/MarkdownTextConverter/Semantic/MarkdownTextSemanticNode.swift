//
//  MarkdownTextSemanticNode.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/15.
//

import Markdown

struct MarkdownTextSemanticDocument {
    var children: [MarkdownTextSemanticNode]
}

enum MarkdownTextSemanticNode {
    case passthrough(any Markup)
    case list(MarkdownTextSemanticList)
    case attachment(MarkdownTextAttachment)
}

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
}

enum MarkdownTextSemanticListMarker {
    case checkbox(Checkbox)
    case text(value: String, monospaced: Bool)
}
