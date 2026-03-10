//
//  MarkdownTextContentEmitter.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

#if canImport(RichText)
import SwiftUI
import Markdown
import RichText

@available(iOS 26, macOS 26, *)
@MainActor
struct MarkdownTextContentEmitter {
    var configuration: MarkdownRendererConfiguration
    var subtreeRenderer: MarkdownSubtreeRenderer
    var attachmentReplacementPolicy: MarkdownAttachmentReplacementPolicy
    
    init(
        configuration: MarkdownRendererConfiguration,
        subtreeRenderer: MarkdownSubtreeRenderer
    ) {
        self.configuration = configuration
        self.subtreeRenderer = subtreeRenderer
        self.attachmentReplacementPolicy = MarkdownAttachmentReplacementPolicy()
    }
    
    func makeTextContent(for semanticDocument: MarkdownSemanticDocument) -> TextContent {
        combine(semanticDocument.rootNodes.map(render))
    }
    
    func makeTextContent(for semanticNode: MarkdownSemanticNode) -> TextContent {
        render(semanticNode)
    }
}

@available(iOS 26, macOS 26, *)
private extension MarkdownTextContentEmitter {
    func render(_ semanticNode: MarkdownSemanticNode) -> TextContent {
        switch semanticNode {
        case .document(let children):
            return combine(children.map(render))

        case .container(let children):
            return combine(children.map(render))

        case .paragraph(let children):
            return TextContent {
                combine(children.map(render))
                LineBreak()
            }

        case .text(let plainText):
            guard configuration.rendersMath else {
                return TextContent(.string(plainText))
            }

            #if canImport(LaTeXSwiftUI)
            let mathParser = MathParser(text: plainText)
            var textContent = TextContent([])
            var processingIndex = plainText.startIndex

            for representation in mathParser.mathRepresentations {
                let range = representation.range
                if processingIndex < range.lowerBound {
                    textContent += TextContent(
                        .string(
                            String(plainText[processingIndex..<range.lowerBound])
                        )
                    )
                }

                let latexText = String(plainText[range])
                textContent += inlineViewContent(
                    sourceRange: nil,
                    replacement: AttributedString(latexText)
                ) {
                    InlineMath(latexText: latexText)
                }

                processingIndex = range.upperBound
            }

            if processingIndex < plainText.endIndex {
                textContent += TextContent(
                    .string(String(plainText[processingIndex..<plainText.endIndex]))
                )
            }

            return textContent
            #else
            return TextContent(.string(plainText))
            #endif

        case .blockDirective(let blockDirective):
            return inlineViewContent(
                sourceRange: blockDirective.range,
                replacement: attachmentReplacementPolicy.replacementForBlockDirective(blockDirective),
                appendsLineBreak: true
            ) {
                MarkdownBlockDirective(blockDirective: blockDirective)
            }

        case .blockQuote(let blockQuote, let children):
            let childAttributedStrings = children.map { child in
                render(child).attributedStringIgnoringViews
            }
            return inlineViewContent(
                sourceRange: blockQuote.range,
                replacement: attachmentReplacementPolicy.replacementForBlockQuote(
                    childAttributedStrings: childAttributedStrings
                ),
                appendsLineBreak: true
            ) {
                MarkdownBlockQuote(blockQuote: blockQuote)
            }

        case .softBreak:
            return RichText.Space(1).textContent

        case .thematicBreak(let sourceRange):
            return inlineViewContent(
                sourceRange: sourceRange,
                replacement: nil,
                appendsLineBreak: true
            ) {
                Divider()
            }

        case .lineBreak:
            return RichText.LineBreak(1).textContent

        case .inlineCode(let code):
            let tintColor = configuration.preferredTintColors[.inlineCodeBlock] ?? .accentColor
            var attributedString = AttributedString(stringLiteral: code)
            attributedString.foregroundColor = tintColor
            attributedString.backgroundColor = tintColor.opacity(0.1)
            return TextContent(.attributedString(attributedString))

        case .inlineHTML(let rawHTML):
            return TextContent(
                .attributedString(
                    AttributedString(
                        rawHTML,
                        attributes: AttributeContainer().isHTML(true)
                    )
                )
            )

        case .image(let image):
            return inlineViewContent(
                sourceRange: image.range,
                replacement: attachmentReplacementPolicy.replacementForImage(image),
                appendsLineBreak: false
            ) {
                MarkdownImage(image: image)
            }

        case .codeBlock(let codeBlock):
            return inlineViewContent(
                sourceRange: codeBlock.range,
                replacement: attachmentReplacementPolicy.replacementForCodeBlock(codeBlock),
                appendsLineBreak: true
            ) {
                MarkdownStyledCodeBlock(
                    configuration: CodeBlockStyleConfiguration(
                        language: codeBlock.language,
                        code: codeBlock.code
                    )
                )
            }

        case .htmlBlock(let htmlBlock):
            return inlineViewContent(
                sourceRange: htmlBlock.range,
                replacement: attachmentReplacementPolicy.replacementForHTMLBlock(htmlBlock),
                appendsLineBreak: true
            ) {
                HTMLBlockView(html: htmlBlock.rawHTML)
            }

        case .list(let semanticList):
            let listItemContents = semanticList.items.map(renderListItem)
            return combine(listItemContents)

        case .listItem(let semanticListItem):
            return renderListItem(semanticListItem)

        case .table(let table):
            let rows = ([table.head as (any TableCellContainer)] + Array(table.body.rows)).map { row in
                Array(row.cells).reduce(into: AttributedString()) { attributedString, cell in
                    attributedString += attributedStringIgnoringAttachments(for: cell)
                    attributedString += "\t"
                }
            }

            return inlineViewContent(
                sourceRange: table.range,
                replacement: attachmentReplacementPolicy.replacementForTableRows(rows),
                appendsLineBreak: true
            ) {
                MarkdownTable(table: table)
            }

        case .tableHead(let tableHead):
            let attributedString = Array(tableHead.cells).reduce(into: AttributedString()) { attributedString, cell in
                attributedString += attributedStringIgnoringAttachments(for: cell)
                attributedString += "\t"
            }

            return TextContent {
                attributedString
                LineBreak()
            }

        case .tableBody(let tableBody):
            let rowContents = Array(tableBody.rows).map { row in
                render(.tableRow(row))
            }
            return combine(rowContents)

        case .tableRow(let tableRow):
            let attributedString = Array(tableRow.cells).reduce(into: AttributedString()) { attributedString, cell in
                attributedString += attributedStringIgnoringAttachments(for: cell)
                attributedString += "\t"
            }

            return TextContent {
                attributedString
                LineBreak()
            }

        case .tableCell(_, let children):
            return combine(children.map(render))

        case .heading(let heading, _):
            let markdownComponent: MarkdownComponent = switch heading.level {
            case 1: .h1
            case 2: .h2
            case 3: .h3
            case 4: .h4
            case 5: .h5
            case 6: .h6
            default: .body
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 12
            paragraphStyle.paragraphSpacingBefore = 12
            let headingLevel = AttributeScopes.AccessibilityAttributes
                .HeadingLevelAttribute
                .HeadingLevel(rawValue: heading.level) ?? .unspecified
            let attributes = AttributeContainer([
                .paragraphStyle: paragraphStyle as NSParagraphStyle
            ])
                .presentationIntent(
                    .init(
                        .header(level: heading.level),
                        identity: heading.indexInParent
                    )
                )
                .accessibilityHeadingLevel(headingLevel)
                .font(configuration.fonts[markdownComponent] ?? .body)

            return TextContent {
                AttributedString(heading.plainText, attributes: attributes)
                LineBreak()
            }

        case .emphasis(let children):
            var mergedAttributedString = AttributedString()
            for child in children {
                let attributedString = render(child).attributedStringIgnoringViews
                guard !attributedString.characters.isEmpty else {
                    continue
                }
                let existingIntent = attributedString.inlinePresentationIntent ?? []
                mergedAttributedString += attributedString.mergingAttributes(
                    AttributeContainer()
                        .inlinePresentationIntent(existingIntent.union(.emphasized))
                )
            }
            return TextContent(.attributedString(mergedAttributedString))

        case .strong(let children):
            var mergedAttributedString = AttributedString()
            for child in children {
                let attributedString = render(child).attributedStringIgnoringViews
                guard !attributedString.characters.isEmpty else {
                    continue
                }
                let existingIntent = attributedString.inlinePresentationIntent ?? []
                mergedAttributedString += attributedString.mergingAttributes(
                    AttributeContainer()
                        .inlinePresentationIntent(existingIntent.union(.stronglyEmphasized))
                )
            }
            return TextContent(.attributedString(mergedAttributedString))

        case .strikethrough(let children):
            var mergedAttributedString = AttributedString()
            for child in children {
                let attributedString = render(child).attributedStringIgnoringViews
                guard !attributedString.characters.isEmpty else {
                    continue
                }
                let existingIntent = attributedString.inlinePresentationIntent ?? []
                mergedAttributedString += attributedString.mergingAttributes(
                    AttributeContainer()
                        .inlinePresentationIntent(existingIntent.union(.strikethrough))
                )
            }
            return TextContent(.attributedString(mergedAttributedString))

        case .link(let destination, let plainText, let sourceRange, let children):
            guard let destination,
                  let destinationURL = URL(string: destination)
            else {
                return combine(children.map(render))
            }

            let linkedContent = combine(children.map(render))
            let tintColor = configuration.preferredTintColors[.link] ?? .accentColor

            let linkedView = linkedContent.fragments.first(byUnwrapping: { fragment in
                if case let .view(attachment) = fragment {
                    return attachment.view
                }
                return nil
            })

            if let linkedView {
                return inlineViewContent(
                    sourceRange: sourceRange,
                    replacement: AttributedString(
                        plainText,
                        attributes: AttributeContainer().link(destinationURL)
                    )
                ) {
                    Link(destination: destinationURL) {
                        linkedView
                    }
                    .foregroundStyle(tintColor)
                }
            }

            let attributedString = linkedContent.attributedStringIgnoringViews
            return TextContent(
                .attributedString(
                    attributedString.mergingAttributes(
                        AttributeContainer()
                            .link(destinationURL)
                            .foregroundColor(tintColor)
                    )
                )
            )
        }
    }

    func renderListItem(_ semanticListItem: MarkdownSemanticListItem) -> TextContent {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = semanticListItem.indentation
        paragraphStyle.firstLineHeadIndent = semanticListItem.indentation

        var markerAttributes = AttributeContainer([
            .paragraphStyle: paragraphStyle as NSParagraphStyle
        ])

        let markerString: String?
        switch semanticListItem.marker {
        case .checkbox(let checkbox):
            markerString = switch checkbox {
            case .checked: "☑︎"
            case .unchecked: "☐"
            }
        case .text(let value, let monospaced):
            markerString = value
            markerAttributes = markerAttributes.font(
                (configuration.fonts[.body] ?? .body)
                    .monospaced(monospaced)
            )
        case .none:
            markerString = nil
        }

        let leadingContent = combine(semanticListItem.leadingChildren.map(render))
        let trailingBlocks = semanticListItem.trailingBlocks.map(render)

        return TextContent {
            if let markerString {
                AttributedString(markerString, attributes: markerAttributes)
            }
            Space()
            if !leadingContent.fragments.isEmpty {
                leadingContent
            }
            LineBreak()

            for trailingBlock in trailingBlocks where !trailingBlock.fragments.isEmpty {
                trailingBlock
            }
        }
    }

    func combine(_ contents: [TextContent]) -> TextContent {
        var mergedContent = TextContent([])
        for content in contents where !content.fragments.isEmpty {
            mergedContent += content
        }
        return mergedContent
    }

    func attributedStringIgnoringAttachments(for markup: any Markup) -> AttributedString {
        let semanticVisitor = MarkdownSemanticVisitor(configuration: configuration)
        let semanticDocument = semanticVisitor.makeDocument(for: markup)
        return makeTextContent(for: semanticDocument).attributedStringIgnoringViews
    }

    func inlineViewContent(
        sourceRange: Range<SourceLocation>?,
        replacement: AttributedString?,
        appendsLineBreak: Bool = false,
        @ViewBuilder content: @escaping () -> some View
    ) -> TextContent {
        let view = content()
            .environment(\.markdownRendererConfiguration, configuration)
            .environment(\.markdownSubtreeRenderer, subtreeRenderer)
        let attachment = InlineHostingAttachment(
            view,
            id: sourceRange,
            replacement: replacement
        )

        return TextContent {
            TextContent(.view(attachment))
            if appendsLineBreak {
                LineBreak()
            }
        }
    }
}

@available(iOS 26, macOS 26, *)
fileprivate extension TextContent {
    var attributedStringIgnoringViews: AttributedString {
        fragments.reduce(into: AttributedString()) { attributedString, fragment in
            switch fragment {
            case .string(let string):
                attributedString += AttributedString(string)
            case .attributedString(let value):
                attributedString += value
            case .view:
                break
            }
        }
    }
}

#endif
