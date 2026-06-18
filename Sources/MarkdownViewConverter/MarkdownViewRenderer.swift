//
//  MarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown
import MarkdownPresentation
import MarkdownRenderingEssentials

@MainActor
@preconcurrency
package struct MarkdownViewRenderer: @preconcurrency MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    var elementRenderers: [MarkdownElementRendererRegistration]
    private var activeInlineIntent: InlinePresentationIntent = []
    
    package init(
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        self.configuration = configuration
        self.elementRenderers = elementRenderers
    }
    
    package func makeBody(for markup: any Markup) -> some View {
        var visitor = self
        return visitor
            .visit(markup)
            .environment(\.markdownRendererConfiguration, configuration)
    }

    package func makeBody(
        for content: MarkdownContent,
        parseOptions: ParseOptions = ParseOptions()
    ) -> some View {
        makeBody(for: content.parse(options: parseOptions))
    }

    package func visitDocument(_ document: Document) -> MarkdownNodeView {
        var renderer = self
        let nodeViews = document.children.map {
            renderer.visit($0)
        }
        return MarkdownNodeView(nodeViews, layoutPolicy: .linebreak)
    }
    
    package func defaultVisit(_ markup: Markdown.Markup) -> MarkdownNodeView {
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
    
    package func visitText(_ text: Markdown.Text) -> MarkdownNodeView {
        if configuration.math.shouldRender {
            InlineMathOrText(text: text.plainText)
                .makeBody(configuration: configuration)
        } else {
            MarkdownNodeView(text.plainText)
        }
    }
    
    package func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownNodeView {
        let fallbackContent = descendInto(blockDirective)
        return MarkdownNodeView {
            MarkdownBlockDirective(
                blockDirective: blockDirective,
                fallbackContent: fallbackContent
            )
        }
    }
    
    package func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownNodeView {
        let content = MarkdownBlockQuoteStyleConfiguration.Content {
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                    MarkdownViewRenderer(
                        configuration: configuration,
                        elementRenderers: elementRenderers
                    )
                    .makeBody(for: child)
                }
            }
        }
        return MarkdownNodeView {
            MarkdownBlockQuote(content: content)
                .tint(configuration.tintColors[.blockQuote, default: .accentColor])
        }
    }
    
    package func visitSoftBreak(_ softBreak: SoftBreak) -> MarkdownNodeView {
        MarkdownNodeView(" ")
    }
    
    package func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownNodeView {
        MarkdownNodeView {
            Divider()
        }
    }
    
    package func visitLineBreak(_ lineBreak: LineBreak) -> MarkdownNodeView {
        MarkdownNodeView("\n")
    }
    
    package func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownNodeView {
        let tintColor = configuration.tintColors[.inlineCodeBlock, default: .accentColor]
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = tintColor
        attributedString.backgroundColor = tintColor.opacity(0.1)
        return MarkdownNodeView(attributedString)
    }
    
    package func visitInlineHTML(_ inlineHTML: InlineHTML) -> MarkdownNodeView {
        MarkdownNodeView(
            AttributedString(
                inlineHTML.rawHTML,
                attributes: AttributeContainer().isHTML(true)
            )
        )
    }
    
    package func visitImage(_ image: Markdown.Image) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownImage(image: image)
        }
    }
    
    package func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownStyledCodeBlock(
                configuration: MarkdownCodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code
                )
            )
        }
    }
    
    package func visitHTMLBlock(_ html: HTMLBlock) -> MarkdownNodeView {
        MarkdownNodeView {
            HTMLBlockView(html: html.rawHTML)
        }
    }
    
    package func visitListItem(_ listItem: ListItem) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownListItem(listItem: listItem)
        }
    }
    
    package func visitOrderedList(_ orderedList: OrderedList) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownList(listItemsContainer: orderedList)
        }
    }
    
    package func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownList(listItemsContainer: unorderedList)
        }
    }
    
    package func visitTable(_ table: Markdown.Table) -> MarkdownNodeView {
        let renderedTable = renderedTable(for: table)
        return MarkdownNodeView {
            MarkdownTable(table: renderedTable)
        }
    }
    
    package func visitTableHead(_ head: Markdown.Table.Head) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: 0,
                cells: Array(head.cells).map(renderedTableCell)
            )
        }
    }
    
    package func visitTableBody(_ body: Markdown.Table.Body) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableBody(rows: renderedTableRows(for: body))
        }
    }
    
    package func visitTableRow(_ row: Markdown.Table.Row) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: row.indexInParent + 1 /* header */,
                cells: Array(row.cells).map(renderedTableCell)
            )
        }
    }
    
    package func visitTableCell(_ cell: Markdown.Table.Cell) -> MarkdownNodeView {
        var cellViews = [MarkdownNodeView]()
        for child in cell.children {
            var renderer = MarkdownViewRenderer(configuration: configuration, elementRenderers: elementRenderers)
            let cellView = renderer.visit(child)
            cellViews.append(cellView)
        }
        return MarkdownNodeView(
            cellViews,
            alignment: cell.horizontalAlignment
        )
    }
    
    package func visitParagraph(_ paragraph: Paragraph) -> MarkdownNodeView {
        defaultVisit(paragraph)
    }
    
    package func visitHeading(_ heading: Heading) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownHeading(heading: heading)
        }
    }
    
    package func visitEmphasis(_ emphasis: Markdown.Emphasis) -> MarkdownNodeView {
        applyInlineIntent(.emphasized, to: emphasis.children)
    }

    package func visitStrong(_ strong: Strong) -> MarkdownNodeView {
        applyInlineIntent(.stronglyEmphasized, to: strong.children)
    }

    package func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownNodeView {
        applyInlineIntent(.strikethrough, to: strikethrough.children)
    }
    
    package func visitLink(_ link: Markdown.Link) -> MarkdownNodeView {
        guard let destination = link.destination,
              let url = URL(string: destination)
        else { return descendInto(link) }
        
        let tintColor = configuration.tintColors[.link, default: .accentColor]
        let underlineLinks = configuration.underlineLinks
        
        let nodeView = descendInto(link)
        let availableRenderers = elementRenderers.compactMap(\.link)
        if availableRenderers.isEmpty == false,
           let urlScheme = url.scheme,
           let linkRenderer = availableRenderers.first(where: { $0.scheme == urlScheme })?.renderer {
            let labelContent: AnyView = nodeView
                .tint(tintColor)
                .underline(underlineLinks)
                .erasedToAnyView()
            let linkConfiguration = MarkdownLinkRendererConfiguration(
                url: url,
                label: labelContent
            )
            return MarkdownNodeView {
                linkRenderer
                    .makeBody(configuration: linkConfiguration)
                    .erasedToAnyView()
            }
        }

        return if let attributedString = nodeView.asAttributedString {
            MarkdownNodeView(
                attributedString.mergingAttributes({
                    var attributes = AttributeContainer()
                        .link(url)
                        .foregroundColor(tintColor)
                    if underlineLinks {
                        attributes.underlineStyle = .single
                    }
                    return attributes
                }())
            )
        } else {
             MarkdownNodeView {
                Link(destination: url) {
                    nodeView
                }
                .foregroundStyle(tintColor)
                .underline(underlineLinks)
            }
        }
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
}

fileprivate extension MarkdownViewRenderer {
    func renderedTable(for table: Markdown.Table) -> MarkdownTableStyleConfiguration.Table {
        MarkdownTableStyleConfiguration.Table(
            headerCells: Array(table.head.cells).map(renderedTableCell),
            bodyRows: renderedTableRows(for: table.body)
        )
    }

    func renderedTableRows(for tableBody: Markdown.Table.Body) -> [MarkdownTableStyleConfiguration.Table.Row] {
        tableBody.rows.map { row in
            MarkdownTableStyleConfiguration.Table.Row(
                rowIndex: row.indexInParent + 1 /* header */,
                cells: Array(row.cells).map(renderedTableCell)
            )
        }
    }

    func renderedTableCell(_ cell: Markdown.Table.Cell) -> MarkdownTableStyleConfiguration.Table.Cell {
        MarkdownTableStyleConfiguration.Table.Cell(
            horizontalAlignment: cell.horizontalAlignment,
            textAlignment: cell.textAlignment,
            colspan: Int(cell.colspan),
            content: MarkdownTableCellContent(cell: cell)
        )
    }
}

private struct MarkdownTableCellContent: View {
    var cell: Markdown.Table.Cell
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers

    var body: some View {
        MarkdownViewRenderer(
            configuration: configuration,
            elementRenderers: elementRenderers
        )
        .makeBody(for: cell)
    }
}
