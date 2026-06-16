//
//  DefaultMarkdownTextAttachmentRenderer.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/16.
//

#if canImport(RichText)
import Markdown
import MarkdownPresentation
import RichText
import SwiftUI

@MainActor
package struct DefaultMarkdownTextAttachmentRenderer: MarkdownTextAttachmentRenderer {
    package init() {}

    package func makeBlockQuoteTextContent(
        for blockQuote: BlockQuote,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        attachmentTextContent(context: context) {
            MarkdownBlockQuote(
                content: MarkdownBlockQuoteStyleConfiguration.Content {
                    MarkdownTextBlockQuoteContent(blockQuote: blockQuote)
                }
            )
        }
    }

    package func makeBlockDirectiveTextContent(
        for blockDirective: BlockDirective,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        attachmentTextContent(context: context) {
            MarkdownBlockDirective(
                blockDirective: blockDirective,
                fallbackContent: MarkdownTextMarkupChildrenContent(markup: blockDirective)
            )
        }
    }

    package func makeImageTextContent(
        for image: Markdown.Image,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        attachmentTextContent(context: context, sizing: .intrinsic) {
            MarkdownImage(image: image)
        }
    }

    package func makeCodeBlockTextContent(
        for codeBlock: CodeBlock,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        attachmentTextContent(context: context) {
            MarkdownStyledCodeBlock(
                configuration: MarkdownCodeBlockStyleConfiguration(
                    language: codeBlock.language,
                    code: codeBlock.code
                )
            )
        }
    }

    package func makeHTMLBlockTextContent(
        for htmlBlock: HTMLBlock,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        attachmentTextContent(context: context) {
            HTMLBlockView(html: htmlBlock.rawHTML)
        }
    }

    package func makeTableTextContent(
        for table: Markdown.Table,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        attachmentTextContent(context: context) {
            MarkdownTable(table: renderedTable(for: table))
        }
    }
}

private extension DefaultMarkdownTextAttachmentRenderer {
    func attachmentTextContent(
        context: MarkdownTextAttachmentContext,
        sizing: HostedAttachmentSizing = .fittingLineFragment,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> TextContent {
        TextContent {
            InlineView(replacement: context.replacement, sizing: sizing) {
                MarkdownTextAttachmentView(appendsLineBreak: context.appendsLineBreak) {
                    content()
                    content()
                }
            }

            if context.appendsLineBreak {
                RichText.LineBreak()
            }
        }
    }

    func renderedTable(for table: Markdown.Table) -> MarkdownTableStyleConfiguration.Table {
        MarkdownTableStyleConfiguration.Table(
            headerCells: Array(table.head.cells).map(renderedTableCell),
            bodyRows: renderedTableRows(for: table.body)
        )
    }

    func renderedTableRows(
        for tableBody: Markdown.Table.Body
    ) -> [MarkdownTableStyleConfiguration.Table.Row] {
        tableBody.rows.map { row in
            MarkdownTableStyleConfiguration.Table.Row(
                rowIndex: row.indexInParent + 1,
                cells: Array(row.cells).map(renderedTableCell)
            )
        }
    }

    func renderedTableCell(
        _ cell: Markdown.Table.Cell
    ) -> MarkdownTableStyleConfiguration.Table.Cell {
        MarkdownTableStyleConfiguration.Table.Cell(
            horizontalAlignment: cell.horizontalAlignment,
            textAlignment: cell.textAlignment,
            colspan: Int(cell.colspan),
            content: MarkdownTextMarkupContent(markup: cell)
        )
    }
}

private struct MarkdownTextAttachmentView<Content: View>: View {
    var appendsLineBreak: Bool
    var content: Content

    @Environment(\.markdownRendererConfiguration) private var presentationConfiguration

    init(
        appendsLineBreak: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.appendsLineBreak = appendsLineBreak
        self.content = content()
    }

    var body: some View {
        content
            .padding(.bottom, appendsLineBreak ? presentationConfiguration.componentSpacing : 0)
    }
}

private struct MarkdownTextBlockQuoteContent: View {
    var blockQuote: BlockQuote

    @Environment(\.markdownRendererConfiguration) private var presentationConfiguration

    var body: some View {
        VStack(alignment: .leading, spacing: presentationConfiguration.componentSpacing) {
            ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                MarkdownTextMarkupContent(markup: child)
            }
        }
    }
}

private struct MarkdownTextMarkupContent: View {
    var markup: any Markup

    @Environment(\.markdownRendererConfiguration) private var presentationConfiguration
    @Environment(\.markdownTextFonts) private var fonts

    var body: some View {
        let converter = MDTextConverter(
            configuration: MarkdownRendererConfiguration(
                presentationConfiguration: presentationConfiguration,
                fonts: fonts
            )
        )

        TextView {
            converter.makeTextContent(for: markup)
        }
    }
}

private struct MarkdownTextMarkupChildrenContent: View {
    var markup: any Markup

    @Environment(\.markdownRendererConfiguration) private var presentationConfiguration
    @Environment(\.markdownTextFonts) private var fonts

    var body: some View {
        let converter = MDTextConverter(
            configuration: MarkdownRendererConfiguration(
                presentationConfiguration: presentationConfiguration,
                fonts: fonts
            )
        )

        TextView {
            for child in markup.children {
                converter.makeTextContent(for: child)
            }
        }
    }
}
#endif
