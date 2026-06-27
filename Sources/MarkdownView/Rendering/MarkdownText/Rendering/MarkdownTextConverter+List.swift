#if canImport(RichText)

import Markdown
import RichText
import SwiftUI

extension MarkdownTextConverter {
    func renderList(_ list: MarkdownTextSemanticList) -> TextContent {
        combineBlocks(list.items.map { renderListItem($0, listDepth: list.depth) })
    }

    func renderListItem(
        _ listItem: MarkdownTextSemanticListItem,
        listDepth: Int
    ) -> TextContent {
        let markerIndentation = CGFloat(listDepth + 1) * configuration.listConfiguration.leadingIndentation
        let bodyIndentation = markerIndentation + configuration.listConfiguration.leadingIndentation
        let listItemParagraphStyle = NSMutableParagraphStyle()
        listItemParagraphStyle.headIndent = bodyIndentation
        listItemParagraphStyle.firstLineHeadIndent = markerIndentation
        listItemParagraphStyle.paragraphSpacing = configuration.componentSpacing
        let continuationParagraphStyle = NSMutableParagraphStyle()
        continuationParagraphStyle.headIndent = bodyIndentation
        continuationParagraphStyle.firstLineHeadIndent = bodyIndentation
        continuationParagraphStyle.paragraphSpacing = configuration.componentSpacing

        let listItemAttributes = AttributeContainer([
            .paragraphStyle: listItemParagraphStyle as NSParagraphStyle,
            .font: fonts.body.asPlatformFont
        ])
        let continuationAttributes = AttributeContainer([
            .paragraphStyle: continuationParagraphStyle as NSParagraphStyle,
            .font: fonts.body.asPlatformFont
        ])
        let markerContent = makeMarkerContent(
            for: listItem.marker,
            sourceMarkup: listItem.sourceMarkup,
            baseAttributes: listItemAttributes
        )
        let leadingContent = combine(listItem.leadingChildren.map(renderMarkup))
        let trailingContent = combineBlocks(listItem.trailingBlocks.map { trailingBlock in
            let content = renderMarkup(trailingBlock)
            return trailingBlock is Paragraph
                ? content.mergingAttributes(continuationAttributes)
                : content
        })

        return TextContent {
            markerContent
            AttributedString(" ", attributes: listItemAttributes)

            if !leadingContent.fragments.isEmpty {
                leadingContent.mergingAttributes(listItemAttributes)
            }

            if !trailingContent.fragments.isEmpty {
                AttributedString("\n", attributes: listItemAttributes)
                trailingContent
            }
        }
    }

    func listMarker(for listItem: ListItem) -> MarkdownTextSemanticListMarker? {
        if let checkbox = listItem.checkbox {
            return .checkbox(checkbox)
        }

        if let unorderedList = listItem.parent as? UnorderedList {
            let marker = configuration.listConfiguration.unorderedListMarker
            return .text(
                value: marker.marker(listDepth: unorderedList.listDepth),
                monospaced: marker.monospaced
            )
        }

        if let orderedList = listItem.parent as? OrderedList {
            let marker = configuration.listConfiguration.orderedListMarker
            return .text(
                value: marker.marker(
                    at: listItem.indexInParent,
                    listDepth: orderedList.listDepth
                ),
                monospaced: marker.monospaced
            )
        }

        return nil
    }
}

private extension MarkdownTextConverter {
    func makeMarkerContent(
        for marker: MarkdownTextSemanticListMarker?,
        sourceMarkup: ListItem,
        baseAttributes: AttributeContainer
    ) -> TextContent {
        switch marker {
        case .checkbox(let checkbox):
                return checkboxTextContent(
                    for: checkbox,
                    sourceMarkup: sourceMarkup
                )
                .mergingAttributes(baseAttributes)
        case .text(let value, let monospaced):
            return TextContent(
                .attributedString(
                    AttributedString(
                        value,
                        attributes: baseAttributes.merging(
                            AttributeContainer([
                                .font: fonts.body.ctFont.monospaced(monospaced)
                            ])
                        )
                    )
                )
            )
        case nil:
            return TextContent([])
        }
    }

    func checkboxTextContent(
        for checkbox: Checkbox,
        sourceMarkup: ListItem
    ) -> TextContent {
        let replacement = switch checkbox {
        case .checked: AttributedString("☑︎")
        case .unchecked: AttributedString("☐")
        }

        return TextContent {
            InlineView(
                id: MarkdownTextInlineViewIdentifier(
                    markup: sourceMarkup,
                    role: .listCheckbox
                ),
                replacement: replacement
            ) {
                MarkdownTextCheckbox(
                    checkbox: checkbox,
                    font: fonts.body._swiftUIFont
                )
            }
        }
    }
}

#endif
