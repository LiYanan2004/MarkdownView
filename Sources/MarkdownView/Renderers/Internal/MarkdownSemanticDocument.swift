//
//  MarkdownSemanticDocument.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

import Foundation
import SwiftUI
import Markdown

@MainActor
struct MarkdownSemanticDocument {
    var rootNodes: [MarkdownSemanticNode]
    
    init(rootNodes: [MarkdownSemanticNode]) {
        self.rootNodes = rootNodes
    }
}

@MainActor
indirect enum MarkdownSemanticNode {
    case document(children: [MarkdownSemanticNode])
    case container(children: [MarkdownSemanticNode])
    case paragraph(children: [MarkdownSemanticNode])

    case text(String)
    case softBreak
    case lineBreak
    case thematicBreak(sourceRange: Range<SourceLocation>?)

    case inlineCode(String)
    case inlineHTML(String)
    case emphasis(children: [MarkdownSemanticNode])
    case strong(children: [MarkdownSemanticNode])
    case strikethrough(children: [MarkdownSemanticNode])
    case link(
        destination: String?,
        plainText: String,
        sourceRange: Range<SourceLocation>?,
        children: [MarkdownSemanticNode]
    )

    case heading(Heading, children: [MarkdownSemanticNode])
    case blockDirective(BlockDirective)
    case blockQuote(BlockQuote, children: [MarkdownSemanticNode])
    case image(Markdown.Image)
    case codeBlock(CodeBlock)
    case htmlBlock(HTMLBlock)

    case list(MarkdownSemanticList)
    case listItem(MarkdownSemanticListItem)

    case table(Markdown.Table)
    case tableHead(Markdown.Table.Head)
    case tableBody(Markdown.Table.Body)
    case tableRow(Markdown.Table.Row)
    case tableCell(Markdown.Table.Cell, children: [MarkdownSemanticNode])
}

@MainActor
struct MarkdownSemanticList {
    enum Kind {
        case ordered
        case unordered
    }
    
    var kind: Kind
    var depth: Int
    var items: [MarkdownSemanticListItem]
}

@MainActor
struct MarkdownSemanticListItem {
    var source: ListItem
    var marker: MarkdownSemanticListMarker?
    var indentation: CGFloat
    var leadingChildren: [MarkdownSemanticNode]
    var trailingBlocks: [MarkdownSemanticNode]
}

@MainActor
enum MarkdownSemanticListMarker {
    case checkbox(Checkbox)
    case text(value: String, monospaced: Bool)
}
