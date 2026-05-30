//
//  CmarkNodeVisitor.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

@MainActor
@preconcurrency
struct CmarkNodeVisitor: @preconcurrency MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    var activeInlineIntent: InlinePresentationIntent = []
    
    func makeBody(for markup: any Markup) -> some View {
        var visitor = self
        return visitor
            .visit(markup)
            .environment(\.markdownRendererConfiguration, configuration)
    }

    func visitDocument(_ document: Document) -> MarkdownNodeView {
        var renderer = self
        let nodeViews = document.children.map {
            renderer.visit($0)
        }
        return MarkdownNodeView(nodeViews, layoutPolicy: .linebreak)
    }
    
    func defaultVisit(_ markup: Markdown.Markup) -> MarkdownNodeView {
        descendInto(markup)
    }
    
    func descendInto(_ markup: any Markup) -> MarkdownNodeView {
        var nodeViews = [MarkdownNodeView]()
        for child in markup.children {
            var renderer = self
            let nodeView = renderer.visit(child)
            nodeViews.append(nodeView)
        }
        return MarkdownNodeView(nodeViews)
    }
    
    func visitText(_ text: Markdown.Text) -> MarkdownNodeView {
        if configuration.math.shouldRender {
            InlineMathOrText(text: text.plainText)
                .makeBody(configuration: configuration)
        } else {
            MarkdownNodeView(text.plainText)
        }
    }
    
    func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownBlockDirective(blockDirective: blockDirective)
        }
    }
    
    func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownBlockQuote(blockQuote: blockQuote)
        }
    }
    
    func visitSoftBreak(_ softBreak: SoftBreak) -> MarkdownNodeView {
        MarkdownNodeView(" ")
    }
    
    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownNodeView {
        MarkdownNodeView {
            Divider()
        }
    }
    
    func visitLineBreak(_ lineBreak: LineBreak) -> MarkdownNodeView {
        MarkdownNodeView("\n")
    }
    
    func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownNodeView {
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = configuration.inlineCodeTintColor
        attributedString.backgroundColor = configuration.inlineCodeTintColor.opacity(0.1)
        return MarkdownNodeView(attributedString)
    }
    
    func visitInlineHTML(_ inlineHTML: InlineHTML) -> MarkdownNodeView {
        MarkdownNodeView(
            AttributedString(
                inlineHTML.rawHTML,
                attributes: AttributeContainer().isHTML(true)
            )
        )
    }
    
    func visitImage(_ image: Markdown.Image) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownImage(image: image)
        }
    }
    
    func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownStyledCodeBlock(
                configuration: CodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code
                )
            )
        }
    }
    
    func visitHTMLBlock(_ html: HTMLBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            HTMLBlockView(html: html.rawHTML)
        }
    }
    
    func visitListItem(_ listItem: ListItem) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownListItem(listItem: listItem)
        }
    }
    
    func visitOrderedList(_ orderedList: OrderedList) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownList(listItemsContainer: orderedList)
        }
    }
    
    func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownList(listItemsContainer: unorderedList)
        }
    }
    
    func visitTable(_ table: Markdown.Table) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTable(table: table)
        }
    }
    
    func visitTableHead(_ head: Markdown.Table.Head) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: 0,
                cells: Array(head.cells)
            )
        }
    }
    
    func visitTableBody(_ body: Markdown.Table.Body) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableBody(tableBody: body)
        }
    }
    
    func visitTableRow(_ row: Markdown.Table.Row) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: row.indexInParent + 1 /* header */,
                cells: Array(row.cells)
            )
        }
    }
    
    func visitTableCell(_ cell: Markdown.Table.Cell) -> MarkdownNodeView {
        var cellViews = [MarkdownNodeView]()
        for child in cell.children {
            var renderer = CmarkNodeVisitor(configuration: configuration)
            let cellView = renderer.visit(child)
            cellViews.append(cellView)
        }
        return MarkdownNodeView(
            cellViews,
            alignment: cell.horizontalAlignment
        )
    }
    
    func visitParagraph(_ paragraph: Paragraph) -> MarkdownNodeView {
        defaultVisit(paragraph)
    }
    
    func visitHeading(_ heading: Heading) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownHeading(heading: heading)
        }
    }
    
    func visitEmphasis(_ emphasis: Markdown.Emphasis) -> MarkdownNodeView {
        applyInlineIntent(.emphasized, to: emphasis.children)
    }

    func visitStrong(_ strong: Strong) -> MarkdownNodeView {
        applyInlineIntent(.stronglyEmphasized, to: strong.children)
    }

    func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownNodeView {
        applyInlineIntent(.strikethrough, to: strikethrough.children)
    }

    private func applyInlineIntent(
        _ newIntent: InlinePresentationIntent,
        to children: MarkupChildren
    ) -> MarkdownNodeView {
        var nodes = [MarkdownNodeView]()
        for child in children {
            var renderer = self
            renderer.activeInlineIntent.formUnion(newIntent)
            let node = renderer.visit(child)
            if let text = node.asAttributedString {
                let intent = text.inlinePresentationIntent ?? []
                let attributedNode = MarkdownNodeView(
                    text.mergingAttributes(
                        AttributeContainer().inlinePresentationIntent(intent.union(newIntent))
                    )
                )
                nodes.append(attributedNode)
            } else {
                nodes.append(node)
            }
        }
        return MarkdownNodeView(nodes)
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> MarkdownNodeView {
        guard let destination = link.destination,
              let url = URL(string: destination)
        else { return descendInto(link) }

        let nodeView = descendInto(link)
        if let urlScheme = url.scheme,
           configuration.allowedLinkRenderers.contains(urlScheme),
           let renderer = MarkdownLinkRenderers.named(urlScheme) {
            let labelContent: AnyView = nodeView
                .foregroundStyle(configuration.linkTintColor)
                .erasedToAnyView()
            let linkConfiguration = MarkdownLinkRendererConfiguration(
                url: url,
                label: labelContent
            )
            return MarkdownNodeView {
                renderer
                    .makeBody(configuration: linkConfiguration)
                    .erasedToAnyView()
                    .foregroundStyle(self.configuration.linkTintColor)
            }
        }

        return if let attributedString = nodeView.asAttributedString {
            MarkdownNodeView(
                attributedString.mergingAttributes(
                    AttributeContainer()
                        .link(url)
                        .foregroundColor(configuration.linkTintColor)
                )
            )
        } else {
             MarkdownNodeView {
                Link(destination: url) {
                    nodeView
                }
                .foregroundStyle(configuration.linkTintColor)
            }
        }
    }
}
