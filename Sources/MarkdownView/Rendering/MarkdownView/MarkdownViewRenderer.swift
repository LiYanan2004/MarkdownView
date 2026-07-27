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
    var quoteAlertEnabled: Bool
    private var activeInlineIntent: InlinePresentationIntent = []

    init(
        configuration: MarkdownRendererConfiguration,
        mathContext: MarkdownMathContext?,
        elementRenderers: [MarkdownElementRendererRegistration],
        quoteAlertEnabled: Bool = false
    ) {
        self.configuration = configuration
        self.mathContext = mathContext
        self.elementRenderers = elementRenderers
        self.quoteAlertEnabled = quoteAlertEnabled
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
        let children = Array(blockQuote.children)
        if quoteAlertEnabled,
           let firstParagraph = children.first as? Paragraph,
           let alert = MarkdownQuoteAlertType.detect(
            from: Self.plainText(of: firstParagraph)
           ) {
            return visitQuoteAlertBlockQuote(
                blockQuote,
                children: children,
                alertType: alert.type,
                title: alert.title
            )
        }

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

    func visitQuoteAlertBlockQuote(
        _ blockQuote: BlockQuote,
        children: [any Markup],
        alertType: MarkdownQuoteAlertType,
        title: String
    ) -> MarkdownNodeView {
        let bodyChildren: [any Markup]
        if children.count > 1 {
            // Blank line separates marker and body.
            bodyChildren = Array(children.dropFirst())
        } else if let firstParagraph = children.first {
            // No blank line: [\!TYPE] and body are in the same paragraph.
            // Strip the [\!TYPE] prefix from the paragraph's inline children.
            let inlineChildren = Array(firstParagraph.children)
            let prefix = "[!\(alertType.rawValue)]"
            let bodyInlineChildren = MarkdownViewRenderer.stripCalloutPrefix(
                from: inlineChildren,
                prefix: prefix
            )
            bodyChildren = bodyInlineChildren
        } else {
            bodyChildren = []
        }

        let content = MarkdownBlockQuoteStyleConfiguration.Content {
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(Array(bodyChildren.enumerated()), id: \.offset) { _, child in
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
            MarkdownQuoteAlert(
                alertType: alertType,
                title: title,
                content: AnyView(content)
            )
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

// MARK: - Utilities

extension MarkdownViewRenderer {
    /// Collects the plain text from a markup node and its inline children,
    /// without any formatting prefixes from ancestral elements.
    static func plainText(of markup: any Markup) -> String {
        if let text = markup as? Markdown.Text {
            return text.string
        }
        if let inlineCode = markup as? InlineCode {
            return inlineCode.code
        }
        if let softBreak = markup as? SoftBreak {
            return softBreak.plainText
        }
        if let lineBreak = markup as? LineBreak {
            return lineBreak.plainText
        }
        if let inlineHTML = markup as? InlineHTML {
            return inlineHTML.plainText
        }
        if let symbolLink = markup as? SymbolLink {
            return symbolLink.plainText
        }
        if let customInline = markup as? CustomInline {
            return customInline.plainText
        }
        return markup.children.reduce(into: "") { $0 += plainText(of: $1) }
    }

    /// Strips the `[!TYPE]` marker from the first Text child of a paragraph's inline children.
    /// Returns the remaining inline children after the marker (and its trailing soft break).
    static func stripCalloutPrefix(
        from inlineChildren: [any Markup],
        prefix: String
    ) -> [any Markup] {
        var result: [any Markup] = []
        var skippedMarker = false

        for child in inlineChildren {
            if !skippedMarker {
                if let text = child as? Markdown.Text, text.string.uppercased().hasPrefix(prefix.uppercased()) {
                    let remaining = String(text.string.dropFirst(prefix.count))
                        .trimmingCharacters(in: .whitespaces)
                    if !remaining.isEmpty {
                        result.append(Markdown.Text(remaining))
                    }
                    skippedMarker = true
                    continue
                }
            }
            // Skip the soft/line break immediately after the marker
            if skippedMarker && result.isEmpty && (child is SoftBreak || child is LineBreak) {
                continue
            }
            result.append(child)
        }

        return result
    }
}
