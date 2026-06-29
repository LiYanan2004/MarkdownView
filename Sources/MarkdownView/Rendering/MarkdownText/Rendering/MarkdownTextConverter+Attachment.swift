#if canImport(RichText)

import Markdown
import RichText
import SwiftUI

extension MarkdownTextConverter {
    func renderAttachment(_ attachment: MarkdownTextAttachment) -> TextContent {
        let replacement = attachmentReplacement(for: attachment)

        let sizing: HostedAttachmentSizing = attachment.markup is Markdown.Image
            ? .intrinsic
            : .fittingLineFragment
        let identifier = MarkdownTextInlineViewIdentifier(
            markup: attachment.markup,
            role: .blockAttachment
        )
        let viewRenderer = MarkdownViewRenderer(
            configuration: configuration,
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
        
        return makeAttachmentTextContent(
            id: identifier,
            replacement: replacement,
            sizing: sizing
        ) {
            viewRenderer.makeBody(for: attachment.markup)
        }
    }
}

fileprivate extension MarkdownTextConverter {
    func makeAttachmentTextContent(
        id: MarkdownTextInlineViewIdentifier,
        replacement: AttributedString?,
        sizing: HostedAttachmentSizing = .fittingLineFragment,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> TextContent {
        MarkdownTextEmbeddingViewFactory.makeTextContent(
            id: id,
            replacement: replacement,
            componentSpacing: configuration.componentSpacing,
            sizing: sizing
        ) {
            content()
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
}

#endif
