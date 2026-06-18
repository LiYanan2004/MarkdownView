#if canImport(RichText)

import Markdown
import MarkdownPresentation
import RichText
import SwiftUI

extension MDTextConverter {
    func renderAttachment(_ attachment: MarkdownTextAttachment) -> TextContent {
        let replacement = attachmentReplacement(for: attachment)

        switch attachment.markup {
        case let blockQuote as BlockQuote:
            return makeAttachmentTextContent(replacement: replacement) {
                MarkdownBlockQuote(
                    content: MarkdownBlockQuoteStyleConfiguration.Content {
                        VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                            ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                                MarkdownTextMarkupContent(markup: child)
                                    .environment(\.markdownFontGroup, blockQuoteFonts)
                            }
                        }
                    }
                )
            }
        case let blockDirective as BlockDirective:
            return makeAttachmentTextContent(replacement: replacement) {
                MarkdownBlockDirective(
                    blockDirective: blockDirective,
                    fallbackContent: MarkdownTextMarkupContent(childrenOf: blockDirective)
                )
            }
        case let image as Markdown.Image:
            return makeAttachmentTextContent(
                replacement: replacement,
                sizing: .intrinsic
            ) {
                MarkdownImage(image: image)
            }
        case let codeBlock as CodeBlock:
            return makeAttachmentTextContent(replacement: replacement) {
                MarkdownStyledCodeBlock(
                    configuration: MarkdownCodeBlockStyleConfiguration(
                        language: codeBlock.language,
                        code: codeBlock.code
                    )
                )
            }
        case let htmlBlock as HTMLBlock:
            return makeAttachmentTextContent(replacement: replacement) {
                HTMLBlockView(html: htmlBlock.rawHTML)
            }
        case let table as Markdown.Table:
            return makeAttachmentTextContent(replacement: replacement) {
                MarkdownTable(table: renderedTable(for: table))
            }
        default:
            return replacement.map {
                TextContent(.attributedString($0))
            } ?? TextContent([])
        }
    }
}

fileprivate extension MDTextConverter {
    var blockQuoteFonts: AnyMarkdownFontGroup {
        var blockQuoteFonts = fonts
        blockQuoteFonts._body = fonts.blockQuote
        return blockQuoteFonts
    }

    func makeAttachmentTextContent(
        replacement: AttributedString?,
        sizing: HostedAttachmentSizing = .fittingLineFragment,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> TextContent {
        MarkdownTextEmbeddingViewFactory.makeTextContent(
            replacement: replacement,
            componentSpacing: configuration.componentSpacing,
            sizing: sizing
        ) {
            content()
                .markdownTextAttachmentEnvironment(from: self)
        }
    }

    func attachmentReplacement(for attachment: MarkdownTextAttachment) -> AttributedString? {
        switch attachment.markup {
        case let blockQuote as BlockQuote:
            let rows = Array(blockQuote.blockChildren).map {
                renderMarkup($0).attributedString()
            }
            guard let firstRow = rows.first else {
                return nil
            }

            return rows.dropFirst().reduce(into: firstRow) { attributedString, row in
                attributedString += "\n"
                attributedString += row
            }
        case let blockDirective as BlockDirective:
            let wrappedString = blockDirective.children
                .compactMap { $0.format() }
                .joined(separator: "\n")
            return wrappedString.isEmpty ? nil : AttributedString(wrappedString)
        case let image as Markdown.Image:
            let alternativeText = image.plainText.trimmingCharacters(in: .whitespacesAndNewlines)
            return alternativeText.isEmpty ? nil : AttributedString(alternativeText)
        case let codeBlock as CodeBlock:
            return codeBlock.code.isEmpty ? nil : AttributedString(codeBlock.code)
        case let htmlBlock as HTMLBlock:
            return htmlBlock.rawHTML.isEmpty ? nil : AttributedString(htmlBlock.rawHTML)
        case let table as Markdown.Table:
            return tableRowsReplacement(for: table)
        default:
            return nil
        }
    }

    func tableRowsReplacement(for table: Markdown.Table) -> AttributedString? {
        let rowContainers: [any TableCellContainer] = [table.head] + Array(table.body.rows)
        guard !rowContainers.isEmpty else {
            return nil
        }

        return rowContainers.reduce(into: AttributedString()) { attributedString, row in
            for cell in row.cells {
                attributedString += renderMarkup(cell).attributedString()
                attributedString += "\t"
            }
            attributedString += "\n"
        }
    }

    func renderedTable(for table: Markdown.Table) -> MarkdownTableStyleConfiguration.Table {
        MarkdownTableStyleConfiguration.Table(
            headerCells: Array(table.head.cells).map(renderedTableCell),
            bodyRows: table.body.rows.map { row in
                MarkdownTableStyleConfiguration.Table.Row(
                    rowIndex: row.indexInParent + 1,
                    cells: Array(row.cells).map(renderedTableCell)
                )
            }
        )
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

#endif
