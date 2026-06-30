//
//  MarkdownTextConverter.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import SwiftUI

#if canImport(RichText)

import RichText
import Markdown

@MainActor
struct MarkdownTextConverter: @MainActor MarkupVisitor {
    var configuration: MarkdownRendererConfiguration
    var mathContext: MarkdownMathContext?
    var elementRenderers: [MarkdownElementRendererRegistration]
    var fonts: AnyMarkdownFontGroup
    var blockQuoteStyle: any MarkdownBlockQuoteStyle
    var codeBlockStyle: any MarkdownCodeBlockStyle
    var tableStyle: any MarkdownTableStyle

    init(
        configuration: MarkdownRendererConfiguration,
        mathContext: MarkdownMathContext?,
        elementRenderers: [MarkdownElementRendererRegistration],
        fonts: AnyMarkdownFontGroup
    ) {
        let environmentValues = EnvironmentValues()

        self.init(
            configuration: configuration,
            mathContext: mathContext,
            elementRenderers: elementRenderers,
            fonts: fonts,
            blockQuoteStyle: environmentValues.blockQuoteStyle,
            codeBlockStyle: environmentValues.codeBlockStyle,
            tableStyle: environmentValues.markdownTableStyle
        )
    }

    init(
        configuration: MarkdownRendererConfiguration,
        mathContext: MarkdownMathContext?,
        elementRenderers: [MarkdownElementRendererRegistration],
        fonts: AnyMarkdownFontGroup,
        blockQuoteStyle: any MarkdownBlockQuoteStyle,
        codeBlockStyle: any MarkdownCodeBlockStyle,
        tableStyle: any MarkdownTableStyle
    ) {
        self.configuration = configuration
        self.mathContext = mathContext
        self.elementRenderers = elementRenderers
        self.fonts = fonts
        self.blockQuoteStyle = blockQuoteStyle
        self.codeBlockStyle = codeBlockStyle
        self.tableStyle = tableStyle
    }

    func makeTextContent(for markup: any Markup) -> TextContent {
        let semanticNodes = MarkdownTextSemanticBuilder(
            configuration: configuration
        )
        .makeNodes(for: markup)

        return render(semanticNodes)
    }

    func makeTextContent(for markups: [any Markup]) -> TextContent {
        render(
            markups.flatMap {
                MarkdownTextSemanticBuilder(configuration: configuration)
                    .makeNodes(for: $0)
            }
        )
    }

    func visitDocument(_ document: Markdown.Document) -> TextContent {
        return render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeNodes(for: document)
        )
    }

    func defaultVisit(_ markup: Markdown.Markup) -> TextContent {
        descendInto(markup)
    }

    func visitParagraph(_ paragraph: Paragraph) -> TextContent {
        paragraphTextContent(descendInto(paragraph))
    }

    func visitHeading(_ heading: Heading) -> TextContent {
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
        paragraphStyle.paragraphSpacing = configuration.componentSpacing

        let headingLevel = AttributeScopes.AccessibilityAttributes
            .HeadingLevelAttribute
            .HeadingLevel(rawValue: heading.level) ?? .unspecified

        let font = switch markdownComponent {
            case .h1: fonts.h1
            case .h2: fonts.h2
            case .h3: fonts.h3
            case .h4: fonts.h4
            case .h5: fonts.h5
            case .h6: fonts.h6
            case .body: fonts.body
            default: preconditionFailure()
        }

        let platformAttributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle as NSParagraphStyle,
            .font: font.asPlatformFont
        ]
        let attributes = AttributeContainer(platformAttributes)
            .presentationIntent(
                .init(
                    .header(level: heading.level),
                    identity: heading.indexInParent
                )
            )
            .accessibilityHeadingLevel(headingLevel)

        return descendInto(heading).mergingAttributes(attributes)
    }

    func visitText(_ text: Markdown.Text) -> TextContent {
        let plainText = text.plainText
        #if ENABLE_MATH_RENDERING
        if mathContext != nil,
           let mathIdentifier = MarkdownMathPreprocessor.displayPlaceholderIdentifier(
               in: plainText
           ) {
            return MarkdownTextEmbeddingViewFactory.makeTextContent(
                id: MarkdownTextInlineViewIdentifier(
                    markup: text,
                    role: .blockAttachment
                ),
                replacement: nil,
                componentSpacing: configuration.componentSpacing,
                sizing: .fittingLineFragment
            ) {
                MarkdownDisplayMathView(mathIdentifier: mathIdentifier)
                    .id(mathIdentifier)
            }
        }
        if mathContext != nil,
           let inlineMathStorage = mathContext?.inlineMathStorage {
            return inlineMathTextContent(
                text: plainText,
                inlineMathStorage: inlineMathStorage,
                sourceMarkup: text
            )
        }
        #endif
        return TextContent(
            .attributedString(
                AttributedString(
                    plainText,
                    attributes: AttributeContainer([.font : fonts.body.asPlatformFont])
                )
            )
        )
    }

    func visitSoftBreak(_ softBreak: SoftBreak) -> TextContent {
        RichText.Space(1).textContent
    }

    func visitLineBreak(_ lineBreak: Markdown.LineBreak) -> TextContent {
        RichText.LineBreak(1).textContent
    }

    func visitThematicBreak(_ thematicBreak: ThematicBreak) -> TextContent {
        TextContent {
            InlineView(
                id: MarkdownTextInlineViewIdentifier(
                    markup: thematicBreak,
                    role: .thematicBreak
                ),
                replacement: AttributedString("---"),
                sizing: .fittingLineFragment
            ) {
                Divider()
                    .padding(.vertical, configuration.componentSpacing)
            }
        }
    }

    func visitBlockQuote(_ blockQuote: BlockQuote) -> TextContent {
        renderAttachment(MarkdownTextAttachment(blockQuote))
    }

    func visitBlockDirective(_ blockDirective: BlockDirective) -> TextContent {
        renderAttachment(MarkdownTextAttachment(blockDirective))
    }

    func visitImage(_ image: Markdown.Image) -> TextContent {
        renderAttachment(MarkdownTextAttachment(image))
    }

    func visitCodeBlock(_ codeBlock: CodeBlock) -> TextContent {
        renderAttachment(MarkdownTextAttachment(codeBlock))
    }

    func visitHTMLBlock(_ htmlBlock: HTMLBlock) -> TextContent {
        renderAttachment(MarkdownTextAttachment(htmlBlock))
    }

    func visitTable(_ table: Markdown.Table) -> TextContent {
        renderAttachment(MarkdownTextAttachment(table))
    }

    func visitInlineCode(_ inlineCode: InlineCode) -> TextContent {
        let tintColor = configuration.tintColors[.inlineCodeBlock] ?? .accentColor
        var attributedString = AttributedString(stringLiteral: inlineCode.code)
        attributedString.foregroundColor = tintColor
        attributedString.backgroundColor = tintColor.opacity(0.1)
        return TextContent(.attributedString(attributedString))
    }

    func visitInlineHTML(_ inlineHTML: InlineHTML) -> TextContent {
        TextContent(.string(inlineHTML.rawHTML))
    }

    func visitEmphasis(_ emphasis: Markdown.Emphasis) -> TextContent {
        mergeInlinePresentationIntent(
            .emphasized,
            children: Array(emphasis.children)
        )
    }

    func visitStrong(_ strong: Strong) -> TextContent {
        mergeInlinePresentationIntent(
            .stronglyEmphasized,
            children: Array(strong.children)
        )
    }

    func visitStrikethrough(_ strikethrough: Strikethrough) -> TextContent {
        mergeInlinePresentationIntent(
            .strikethrough,
            children: Array(strikethrough.children)
        )
    }

    func visitLink(_ link: Markdown.Link) -> TextContent {
        guard let destination = link.destination,
              let url = configuration.resolvedMarkdownURL(for: destination)
        else { return descendInto(link) }

        if let linkRenderer = linkRenderer(for: url) {
            return MarkdownTextEmbeddingViewFactory.makeTextContent(
                id: MarkdownTextInlineViewIdentifier(
                    markup: link,
                    role: .customLink
                ),
                replacement: linkReplacement(for: link, url: url),
                componentSpacing: configuration.componentSpacing,
                sizing: .intrinsic
            ) {
                MarkdownCustomLink(
                    link: link,
                    url: url,
                    renderer: linkRenderer,
                    configuration: configuration,
                    elementRenderers: elementRenderers
                )
            }
        }

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

    func visitOrderedList(_ orderedList: OrderedList) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeNodes(for: orderedList)
        )
    }

    func visitUnorderedList(_ unorderedList: UnorderedList) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeNodes(for: unorderedList)
        )
    }

    func visitListItem(_ listItem: ListItem) -> TextContent {
        return renderListItem(
            MarkdownTextSemanticListItem(
                marker: listMarker(for: listItem),
                sourceMarkup: listItem
            ),
            listDepth: (listItem.parent as? ListItemContainer)?.listDepth ?? 0
        )
    }
}

extension MarkdownTextConverter {
    func render(_ nodes: [MarkdownTextSemanticNode]) -> TextContent {
        combineBlocks(nodes.map(render))
    }

    func render(_ node: MarkdownTextSemanticNode) -> TextContent {
        switch node {
        case .passthrough(let markup):
            renderMarkup(markup)
        case .list(let list):
            renderList(list)
        case .attachment(let attachment):
            renderAttachment(attachment)
        }
    }

    func renderMarkup(_ markup: any Markup) -> TextContent {
        var converter = self
        return converter.visit(markup)
    }

    func descendInto(_ markup: any Markup) -> TextContent {
        combine(markup.children.map(renderMarkup))
    }

    func combine(_ contents: [TextContent]) -> TextContent {
        contents.reduce(into: TextContent([])) { combined, content in
            if !content.fragments.isEmpty {
                combined += content
            }
        }
    }

    func paragraphTextContent(_ content: TextContent) -> TextContent {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = configuration.componentSpacing
        let attributes = AttributeContainer([
            .paragraphStyle: paragraphStyle as NSParagraphStyle,
            .font: fonts.body.asPlatformFont
        ])

        return content.mergingAttributes(attributes)
    }

    func combineBlocks(_ contents: [TextContent]) -> TextContent {
        contents.reduce(into: TextContent([])) { combined, content in
            guard !content.fragments.isEmpty else {
                return
            }

            if !combined.fragments.isEmpty {
                combined += RichText.LineBreak().textContent
            }
            combined += content
        }
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
}

#endif
