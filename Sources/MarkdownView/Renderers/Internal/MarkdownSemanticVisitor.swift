//
//  MarkdownSemanticVisitor.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

import Foundation
import SwiftUI
import Markdown

@MainActor
@preconcurrency
struct MarkdownSemanticVisitor: @preconcurrency MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    
    init(configuration: MarkdownRendererConfiguration) {
        self.configuration = configuration
    }
    
    func makeDocument(for markup: any Markup) -> MarkdownSemanticDocument {
        let semanticNode = makeNode(for: markup)
        switch semanticNode {
        case .document(let children):
            return MarkdownSemanticDocument(rootNodes: children)
        default:
            return MarkdownSemanticDocument(rootNodes: [semanticNode])
        }
    }
    
    func makeNodes(descendingInto markup: any Markup) -> [MarkdownSemanticNode] {
        makeNodes(for: Array(markup.children))
    }
    
    func visitDocument(_ document: Document) -> MarkdownSemanticNode {
        .document(children: makeNodes(for: Array(document.children)))
    }
    
    func defaultVisit(_ markup: Markdown.Markup) -> MarkdownSemanticNode {
        .container(children: makeNodes(for: Array(markup.children)))
    }
    
    func visitParagraph(_ paragraph: Paragraph) -> MarkdownSemanticNode {
        .paragraph(children: makeNodes(for: Array(paragraph.children)))
    }
    
    func visitText(_ text: Markdown.Text) -> MarkdownSemanticNode {
        .text(text.plainText)
    }
    
    func visitSoftBreak(_ softBreak: SoftBreak) -> MarkdownSemanticNode {
        .softBreak
    }
    
    func visitLineBreak(_ lineBreak: Markdown.LineBreak) -> MarkdownSemanticNode {
        .lineBreak
    }
    
    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownSemanticNode {
        .thematicBreak(sourceRange: thematicBreak.range)
    }
    
    func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownSemanticNode {
        .inlineCode(inlineCode.code)
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> MarkdownSemanticNode {
        .inlineHTML(inlineHTML.rawHTML)
    }
    
    func visitEmphasis(_ emphasis: Markdown.Emphasis) -> MarkdownSemanticNode {
        .emphasis(children: makeNodes(for: Array(emphasis.children)))
    }
    
    func visitStrong(_ strong: Strong) -> MarkdownSemanticNode {
        .strong(children: makeNodes(for: Array(strong.children)))
    }
    
    func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownSemanticNode {
        .strikethrough(children: makeNodes(for: Array(strikethrough.children)))
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> MarkdownSemanticNode {
        .link(
            destination: link.destination,
            plainText: link.plainText,
            sourceRange: link.range,
            children: makeNodes(for: Array(link.children))
        )
    }
    
    func visitHeading(_ heading: Heading) -> MarkdownSemanticNode {
        .heading(heading, children: makeNodes(for: Array(heading.children)))
    }
    
    func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownSemanticNode {
        .blockDirective(blockDirective)
    }
    
    func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownSemanticNode {
        .blockQuote(blockQuote, children: makeNodes(for: Array(blockQuote.blockChildren)))
    }
    
    func visitImage(_ image: Markdown.Image) -> MarkdownSemanticNode {
        .image(image)
    }
    
    func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownSemanticNode {
        .codeBlock(codeBlock)
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> MarkdownSemanticNode {
        .htmlBlock(html)
    }
    
    func visitOrderedList(_ orderedList: OrderedList) -> MarkdownSemanticNode {
        .list(
            MarkdownSemanticList(
                kind: .ordered,
                depth: orderedList.listDepth,
                items: makeSemanticListItems(from: orderedList)
            )
        )
    }
    
    func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownSemanticNode {
        .list(
            MarkdownSemanticList(
                kind: .unordered,
                depth: unorderedList.listDepth,
                items: makeSemanticListItems(from: unorderedList)
            )
        )
    }
    
    func visitListItem(_ listItem: ListItem) -> MarkdownSemanticNode {
        .listItem(makeSemanticListItem(from: listItem))
    }
    
    func visitTable(_ table: Markdown.Table) -> MarkdownSemanticNode {
        .table(table)
    }
    
    func visitTableHead(_ head: Markdown.Table.Head) -> MarkdownSemanticNode {
        .tableHead(head)
    }
    
    func visitTableBody(_ body: Markdown.Table.Body) -> MarkdownSemanticNode {
        .tableBody(body)
    }
    
    func visitTableRow(_ row: Markdown.Table.Row) -> MarkdownSemanticNode {
        .tableRow(row)
    }
    
    func visitTableCell(_ cell: Markdown.Table.Cell) -> MarkdownSemanticNode {
        .tableCell(cell, children: makeNodes(for: Array(cell.children)))
    }
}

private extension MarkdownSemanticVisitor {
    func makeNode(for markup: any Markup) -> MarkdownSemanticNode {
        var semanticVisitor = self
        return semanticVisitor.visit(markup)
    }
    
    func makeNodes(for markups: [Markup]) -> [MarkdownSemanticNode] {
        markups.map(makeNode(for:))
    }
    
    func makeSemanticListItems(
        from listItemContainer: some ListItemContainer
    ) -> [MarkdownSemanticListItem] {
        listItemContainer.listItems.map(makeSemanticListItem(from:))
    }
    
    func makeSemanticListItem(from listItem: ListItem) -> MarkdownSemanticListItem {
        let depth = (listItem.parent as? ListItemContainer)?.listDepth ?? 0
        let indentation = CGFloat(depth) * configuration.list.leadingIndentation

        let marker: MarkdownSemanticListMarker?
        if let checkbox = listItem.checkbox {
            marker = .checkbox(checkbox)
        } else if let unorderedList = listItem.parent as? UnorderedList {
            let unorderedMarker = configuration.list.unorderedListMarker
            marker = .text(
                value: unorderedMarker.marker(listDepth: unorderedList.listDepth),
                monospaced: unorderedMarker.monospaced
            )
        } else if let orderedList = listItem.parent as? OrderedList {
            let orderedMarker = configuration.list.orderedListMarker
            marker = .text(
                value: orderedMarker.marker(
                    at: listItem.indexInParent,
                    listDepth: orderedList.listDepth
                ),
                monospaced: orderedMarker.monospaced
            )
        } else {
            marker = nil
        }

        let children = Array(listItem.children)
        let leadingChildren: [MarkdownSemanticNode]
        let trailingBlocks: [MarkdownSemanticNode]
        if let firstChild = children.first {
            leadingChildren = makeNodes(for: Array(firstChild.children))
            trailingBlocks = children.dropFirst().map(makeNode(for:))
        } else {
            leadingChildren = []
            trailingBlocks = []
        }

        return MarkdownSemanticListItem(
            source: listItem,
            marker: marker,
            indentation: indentation,
            leadingChildren: leadingChildren,
            trailingBlocks: trailingBlocks
        )
    }
}
