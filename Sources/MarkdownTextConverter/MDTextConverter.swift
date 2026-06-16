//
//  MDTextConverter.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import Foundation
import SwiftUI
import Markdown
import RichText
import MarkdownRenderingEssentials

@MainActor
package struct MDTextConverter: @MainActor MarkupVisitor {
    package var configuration: MarkdownRendererConfiguration

    package init(configuration: MarkdownRendererConfiguration) {
        self.configuration = configuration
    }

    package func makeTextContent(for markup: any Markup) -> TextContent {
        let semanticDocument = MarkdownTextSemanticBuilder(
            configuration: configuration
        )
        .makeDocument(for: markup)

        return render(semanticDocument)
    }

    package func visitDocument(_ document: Document) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeDocument(for: document)
        )
    }

    package func defaultVisit(_ markup: Markdown.Markup) -> TextContent {
        descendInto(markup)
    }

    package func visitParagraph(_ paragraph: Paragraph) -> TextContent {
        paragraphTextContent(descendInto(paragraph))
    }

    package func visitHeading(_ heading: Heading) -> TextContent {
        let markdownComponent = markdownComponent(forHeadingLevel: heading.level)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = configuration.componentSpacing
        paragraphStyle.paragraphSpacingBefore = configuration.componentSpacing

        let headingLevel = AttributeScopes.AccessibilityAttributes
            .HeadingLevelAttribute
            .HeadingLevel(rawValue: heading.level) ?? .unspecified

        let attributes = AttributeContainer([
            .paragraphStyle: paragraphStyle as NSParagraphStyle,
            .font: (configuration.fonts[markdownComponent] ?? bodyFont).asPlatformFont
        ])
            .presentationIntent(
                .init(
                    .header(level: heading.level),
                    identity: heading.indexInParent
                )
            )
            .accessibilityHeadingLevel(headingLevel)

        return TextContent(
            descendInto(heading).mergingAttributes(attributes).fragments + [
                .attributedString(AttributedString("\n", attributes: attributes))
            ]
        )
    }

    package func visitText(_ text: Markdown.Text) -> TextContent {
        let plainText = text.plainText
        guard configuration.math.shouldRender else {
            return TextContent(.string(plainText))
        }

        return TextContent(.string(plainText))
    }

    package func visitSoftBreak(_ softBreak: SoftBreak) -> TextContent {
        RichText.Space(1).textContent
    }

    package func visitLineBreak(_ lineBreak: Markdown.LineBreak) -> TextContent {
        RichText.LineBreak(1).textContent
    }

    package func visitThematicBreak(_ thematicBreak: ThematicBreak) -> TextContent {
        TextContent {
            InlineView(replacement: nil, sizing: .fittingLineFragment) {
                Divider()
            }
            RichText.LineBreak()
        }
    }

    package func visitBlockQuote(_ blockQuote: BlockQuote) -> TextContent {
        renderAttachment(MarkdownTextAttachment(blockQuote))
    }

    package func visitBlockDirective(_ blockDirective: BlockDirective) -> TextContent {
        renderAttachment(MarkdownTextAttachment(blockDirective))
    }

    package func visitImage(_ image: Markdown.Image) -> TextContent {
        renderAttachment(MarkdownTextAttachment(image))
    }

    package func visitCodeBlock(_ codeBlock: CodeBlock) -> TextContent {
        renderAttachment(MarkdownTextAttachment(codeBlock))
    }

    package func visitHTMLBlock(_ htmlBlock: HTMLBlock) -> TextContent {
        renderAttachment(MarkdownTextAttachment(htmlBlock))
    }

    package func visitTable(_ table: Markdown.Table) -> TextContent {
        renderAttachment(MarkdownTextAttachment(table))
    }

    package func visitInlineCode(_ inlineCode: InlineCode) -> TextContent {
        let tintColor = configuration.tintColors[.inlineCodeBlock] ?? .accentColor
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = tintColor
        attributedString.backgroundColor = tintColor.opacity(0.1)
        return TextContent(.attributedString(attributedString))
    }

    package func visitInlineHTML(_ inlineHTML: InlineHTML) -> TextContent {
        if let attributedString = try? AttributedString(
            NSAttributedString(
                data: Data(inlineHTML.rawHTML.utf8),
                options: [
                    .documentType: NSAttributedString.DocumentType.html
                ],
                documentAttributes: nil
            )
        ) {
            return TextContent(.attributedString(attributedString))
        }

        return TextContent(.string(inlineHTML.rawHTML))
    }

    package func visitEmphasis(_ emphasis: Markdown.Emphasis) -> TextContent {
        mergeInlinePresentationIntent(
            .emphasized,
            children: Array(emphasis.children)
        )
    }

    package func visitStrong(_ strong: Strong) -> TextContent {
        mergeInlinePresentationIntent(
            .stronglyEmphasized,
            children: Array(strong.children)
        )
    }

    package func visitStrikethrough(_ strikethrough: Strikethrough) -> TextContent {
        mergeInlinePresentationIntent(
            .strikethrough,
            children: Array(strikethrough.children)
        )
    }

    package func visitLink(_ link: Markdown.Link) -> TextContent {
        guard let destination = link.destination,
              let url = URL(string: destination, relativeTo: configuration.preferredBaseURL)
        else { return descendInto(link) }

        var attributes = AttributeContainer()
            .link(url)
            .foregroundColor(configuration.tintColors[.link] ?? .accentColor)

        if configuration.underlineLinks {
            attributes.underlineStyle = .single
        } else {
            attributes.underlineStyle = .none
        }

        return TextContent(
            .attributedString(
                descendInto(link)
                    .attributedString()
                    .mergingAttributes(attributes)
            )
        )
    }

    package func visitOrderedList(_ orderedList: OrderedList) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeDocument(for: orderedList)
        )
    }

    package func visitUnorderedList(_ unorderedList: UnorderedList) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeDocument(for: unorderedList)
        )
    }

    package func visitListItem(_ listItem: ListItem) -> TextContent {
        let children = Array(listItem.children)
        let leadingChildren = children.first.map { Array($0.children) } ?? []
        let trailingBlocks = Array(children.dropFirst())

        return renderListItem(
            MarkdownTextSemanticListItem(
                marker: listMarker(for: listItem),
                sourceMarkup: listItem,
                leadingChildren: leadingChildren,
                trailingBlocks: trailingBlocks
            ),
            listDepth: (listItem.parent as? ListItemContainer)?.listDepth ?? 0
        )
    }
}

private extension MDTextConverter {
    func render(_ document: MarkdownTextSemanticDocument) -> TextContent {
        combine(document.children.map(render))
    }

    func render(_ node: MarkdownTextSemanticNode) -> TextContent {
        switch node {
        case .passthrough(let markup):
            return renderMarkup(markup)
        case .list(let list):
            return renderList(list)
        case .attachment(let attachment):
            return renderAttachment(attachment)
        }
    }

    func renderMarkup(_ markup: any Markup) -> TextContent {
        var converter = self
        return converter.visit(markup)
    }

    func renderList(_ list: MarkdownTextSemanticList) -> TextContent {
        combine(
            list.items.map {
                renderListItem($0, listDepth: list.depth)
            }
        )
    }

    func renderListItem(
        _ listItem: MarkdownTextSemanticListItem,
        listDepth: Int
    ) -> TextContent {
        let indentation = CGFloat(listDepth + 1) * configuration.listConfiguration.leadingIndentation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = indentation
        paragraphStyle.firstLineHeadIndent = indentation
        paragraphStyle.paragraphSpacing = configuration.componentSpacing

        let listItemAttributes = AttributeContainer([
            .paragraphStyle: paragraphStyle as NSParagraphStyle
        ])

        var markerAttributes = listItemAttributes
        let markerString: String?

        switch listItem.marker {
        case .checkbox(.checked):
            markerString = nil
        case .checkbox(.unchecked):
            markerString = nil
        case .text(let value, let monospaced):
            markerString = value
            markerAttributes = markerAttributes.merging(
                AttributeContainer([
                    .font: bodyFont.ctFont.monospaced(monospaced)
                ])
            )
        case .none:
            markerString = nil
        }

        let leadingContent = combine(listItem.leadingChildren.map(renderMarkup))
        let trailingBlocks = listItem.trailingBlocks.map(renderMarkup)
        let checkboxContent: TextContent?

        if case .checkbox(let checkbox) = listItem.marker {
            checkboxContent = checkboxViewContent(for: checkbox)
        } else {
            checkboxContent = nil
        }

        return TextContent {
            if let checkboxContent {
                checkboxContent.mergingAttributes(listItemAttributes)
            }

            if let markerString {
                AttributedString(markerString, attributes: markerAttributes)
            }

            AttributedString(" ", attributes: listItemAttributes)

            if !leadingContent.fragments.isEmpty {
                leadingContent.mergingAttributes(listItemAttributes)
            }

            AttributedString("\n", attributes: listItemAttributes)

            for trailingBlock in trailingBlocks where !trailingBlock.fragments.isEmpty {
                trailingBlock
            }
        }
    }

    var bodyFont: any CustomCTFontConvertible {
        configuration.fonts[.body] ?? PlatformFont.systemFont(ofSize: PlatformFont.systemFontSize)
    }

    func markdownComponent(forHeadingLevel headingLevel: Int) -> MarkdownComponent {
        switch headingLevel {
        case 1: .h1
        case 2: .h2
        case 3: .h3
        case 4: .h4
        case 5: .h5
        case 6: .h6
        default: .body
        }
    }

    func checkboxViewContent(for checkbox: Checkbox) -> TextContent {
        let replacement: AttributedString = switch checkbox {
        case .checked: AttributedString("☑︎")
        case .unchecked: AttributedString("☐")
        }

        return TextContent {
            InlineView(replacement: replacement) {
                MarkdownTextCheckbox(checkbox: checkbox)
            }
        }
    }

    func renderAttachment(_ attachment: MarkdownTextAttachment) -> TextContent {
        let context = MarkdownTextAttachmentContext(
            attachment: attachment,
            replacement: replacement(for: attachment),
            appendsLineBreak: appendsLineBreak(after: attachment)
        )

        switch attachment.markup {
        case let blockQuote as BlockQuote:
            return configuration.attachmentRenderer.makeBlockQuoteTextContent(
                for: blockQuote,
                context: context
            )
        case let blockDirective as BlockDirective:
            return configuration.attachmentRenderer.makeBlockDirectiveTextContent(
                for: blockDirective,
                context: context
            )
        case let image as Markdown.Image:
            return configuration.attachmentRenderer.makeImageTextContent(
                for: image,
                context: context
            )
        case let codeBlock as CodeBlock:
            return configuration.attachmentRenderer.makeCodeBlockTextContent(
                for: codeBlock,
                context: context
            )
        case let htmlBlock as HTMLBlock:
            return configuration.attachmentRenderer.makeHTMLBlockTextContent(
                for: htmlBlock,
                context: context
            )
        case let table as Markdown.Table:
            return configuration.attachmentRenderer.makeTableTextContent(
                for: table,
                context: context
            )
        default:
            return context.fallbackTextContent
        }
    }

    func replacement(for attachment: MarkdownTextAttachment) -> AttributedString? {
        switch attachment.markup {
            case let blockQuote as BlockQuote:
                let rows = Array(blockQuote.blockChildren).map {
                    renderMarkup($0).attributedString()
                }

                guard let firstRow = rows.first else { return nil }

                return rows.dropFirst().reduce(into: firstRow) { attributedString, row in
                    attributedString += "\n"
                    attributedString += row
                }
                
            case let blockDirective as BlockDirective:
                let wrappedString = blockDirective.children
                    .compactMap { $0.format() }
                    .joined(separator: "\n")
                guard !wrappedString.isEmpty else {
                    return nil
                }
                return AttributedString(wrappedString)
                
            case let image as Markdown.Image:
                let alternativeText = image.plainText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !alternativeText.isEmpty else {
                    return nil
                }
                return AttributedString(alternativeText)
                
            case let codeBlock as CodeBlock:
                guard !codeBlock.code.isEmpty else {
                    return nil
                }
                return AttributedString(codeBlock.code)
                
            case let htmlBlock as HTMLBlock:
                guard !htmlBlock.rawHTML.isEmpty else {
                    return nil
                }
                return AttributedString(htmlBlock.rawHTML)
                
            case let table as Markdown.Table:
                return tableRowsReplacement(for: table)
                
            default:
                return nil
        }
    }
    
    func appendsLineBreak(after attachment: MarkdownTextAttachment) -> Bool {
        switch attachment.markup {
            case is Markdown.Image:
                return false // image could be inline with text
            case is Markdown.BlockQuote:
                return true
            default:
                return true
        }
    }

    func tableRowsReplacement(for table: Markdown.Table) -> AttributedString? {
        let rowContainers: [any TableCellContainer] = [table.head] + Array(table.body.rows)
        let rows = rowContainers.map { row in
            Array(row.cells).reduce(into: AttributedString()) { attributedString, cell in
                attributedString += renderMarkup(cell).attributedString()
                attributedString += "\t"
            }
        }

        guard !rows.isEmpty else {
            return nil
        }

        return rows.reduce(into: AttributedString()) { attributedString, row in
            attributedString += row
            attributedString += "\n"
        }
    }

    func descendInto(_ markup: any Markup) -> TextContent {
        combine(markup.children.map(renderMarkup))
    }

    func combine(_ contents: [TextContent]) -> TextContent {
        var combined = TextContent([])
        for content in contents where !content.fragments.isEmpty {
            combined += content
        }
        return combined
    }

    func paragraphTextContent(_ content: TextContent) -> TextContent {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = configuration.componentSpacing
        let attributes = AttributeContainer([
            .paragraphStyle: paragraphStyle as NSParagraphStyle
        ])

        return TextContent(
            content.mergingAttributes(attributes).fragments + [
                .attributedString(AttributedString("\n", attributes: attributes))
            ]
        )
    }

    func mergeInlinePresentationIntent(
        _ inlinePresentationIntent: InlinePresentationIntent,
        children: [any Markup]
    ) -> TextContent {
        let attributedString = children.reduce(into: AttributedString()) { result, child in
            let childAttributedString = renderMarkup(child).attributedString()
            guard !childAttributedString.characters.isEmpty else {
                return
            }

            let existingIntent = childAttributedString.inlinePresentationIntent ?? []
            result += childAttributedString.mergingAttributes(
                AttributeContainer()
                    .inlinePresentationIntent(existingIntent.union(inlinePresentationIntent))
            )
        }

        return TextContent(.attributedString(attributedString))
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

private struct MarkdownTextCheckbox: View {
    var checkbox: Checkbox

    var body: some View {
        switch checkbox {
        case .checked:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.tint)
        case .unchecked:
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
        }
    }
}

fileprivate extension TextContent {
    @MainActor
    func mergingAttributes(_ attributes: AttributeContainer) -> TextContent {
        TextContent(
            fragments.map { fragment in
                switch fragment {
                case .string(let string):
                    .attributedString(AttributedString(string, attributes: attributes))
                case .attributedString(let attributedString):
                    .attributedString(attributedString.mergingAttributes(attributes))
                case .view:
                    .attributedString(fragment.asAttributedString().mergingAttributes(attributes))
                }
            }
        )
    }
    
    @MainActor
    func attributedString(options: AttributedStringOption = []) -> AttributedString {
        fragments.reduce(into: AttributedString()) { attributedString, fragment in
            switch fragment {
                case .string(let string):
                    attributedString += AttributedString(string)
                case .attributedString(let value):
                    attributedString += value
                case .view:
                    if options.contains(.ignoresEmbeddedView) == false {
                        attributedString += fragment.asAttributedString()
                    }
            }
        }
    }
    
    struct AttributedStringOption: OptionSet {
        var rawValue: UInt8
        
        static let ignoresEmbeddedView = AttributedStringOption(rawValue: 1 << 0)
    }
}
