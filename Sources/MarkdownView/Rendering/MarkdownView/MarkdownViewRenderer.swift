//
//  MarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

@MainActor
@preconcurrency
struct MarkdownViewRenderer: @preconcurrency MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    var mathContext: MarkdownMathContext?
    var elementRenderers: [MarkdownElementRendererRegistration]
    private var activeInlineIntent: InlinePresentationIntent = []
    
    init(
        configuration: MarkdownRendererConfiguration,
        mathContext: MarkdownMathContext?,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) {
        self.configuration = configuration
        self.mathContext = mathContext
        self.elementRenderers = elementRenderers
    }
    
    func makeBody(for markup: any Markup) -> some View {
        var visitor = self
        return visitor
            .visit(markup)
            .environment(\.markdownMathContext, mathContext)
            .environment(\.markdownElementRenderers, elementRenderers)
    }
    
    func makeBody(forChildrenOf markup: any Markup) -> some View {
        self
            .descendInto(markup)
            .environment(\.markdownMathContext, mathContext)
            .environment(\.markdownElementRenderers, elementRenderers)
    }

    func visitDocument(_ document: Markdown.Document) -> MarkdownNodeView {
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
        if mathContext != nil,
           let mathIdentifier = MarkdownMathPreprocessor.displayPlaceholderIdentifier(
               in: text.plainText
           ) {
            return MarkdownNodeView {
                MarkdownDisplayMathView(mathIdentifier: mathIdentifier)
                    .id(mathIdentifier)
            }
        }

        if mathContext != nil {
            return InlineMathOrText(text: text.plainText)
                .makeBody(mathContext: mathContext)
        }

        return MarkdownNodeView(text.plainText)
    }
    
    func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownNodeView {
        let fallbackContent = descendInto(blockDirective)
        return MarkdownNodeView {
            MarkdownBlockDirective(
                blockDirective: blockDirective,
                fallbackContent: fallbackContent
            )
        }
    }
    
    func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownNodeView {
        let content = MarkdownBlockQuoteStyleConfiguration.Content {
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                    MarkdownViewRenderer(
                        configuration: configuration,
                        mathContext: mathContext,
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
        let tintColor = configuration.tintColors[.inlineCodeBlock, default: .accentColor]
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = tintColor
        attributedString.backgroundColor = tintColor.opacity(0.1)
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
                configuration: MarkdownCodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code.trimmingCharacters(in: .newlines)
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
        let renderedTable = renderedTable(for: table)
        return MarkdownNodeView {
            MarkdownTable(table: renderedTable)
        }
    }
    
    func visitTableHead(_ head: Markdown.Table.Head) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: 0,
                cells: Array(head.cells).map(renderedTableCell)
            )
        }
    }
    
    func visitTableBody(_ body: Markdown.Table.Body) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableBody(rows: renderedTableRows(for: body))
        }
    }
    
    func visitTableRow(_ row: Markdown.Table.Row) -> MarkdownNodeView {
        MarkdownNodeView {
            MarkdownTableRow(
                rowIndex: row.indexInParent + 1 /* header */,
                cells: Array(row.cells).map(renderedTableCell)
            )
        }
    }
    
    func visitTableCell(_ cell: Markdown.Table.Cell) -> MarkdownNodeView {
        var cellViews = [MarkdownNodeView]()
        for child in cell.children {
            var renderer = MarkdownViewRenderer(
                configuration: configuration,
                mathContext: mathContext,
                elementRenderers: elementRenderers
            )
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
    
    func visitLink(_ link: Markdown.Link) -> MarkdownNodeView {
        guard let destination = link.destination,
              let url = configuration.resolvedMarkdownURL(for: destination)
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
        let content = MarkdownViewRenderer(
            configuration: configuration,
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
        .makeBody(for: cell)
        
        return MarkdownTableStyleConfiguration.Table.Cell(
            horizontalAlignment: cell.horizontalAlignment,
            textAlignment: cell.textAlignment,
            colspan: Int(cell.colspan),
            content: content
        )
    }
}
