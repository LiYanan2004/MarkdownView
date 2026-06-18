//
//  MDTextConverter.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import SwiftUI

#if canImport(RichText)

import RichText
import Markdown
import MarkdownMathPlugin
import MarkdownPresentation
import MarkdownRenderingEssentials

#if canImport(LaTeXSwiftUI)
import LaTeXSwiftUI
#endif

@MainActor
package struct MDTextConverter: @MainActor MarkupVisitor {
    package var configuration: MarkdownPresentation.MarkdownRendererConfiguration
    package var elementRenderers: [MarkdownElementRendererRegistration]
    package var fonts: AnyMarkdownFontGroup
    package var blockQuoteStyle: any MarkdownBlockQuoteStyle
    package var codeBlockStyle: any MarkdownCodeBlockStyle
    package var tableStyle: any MarkdownTableStyle

    package init(
        configuration: MarkdownPresentation.MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration],
        fonts: AnyMarkdownFontGroup
    ) {
        let environmentValues = EnvironmentValues()

        self.init(
            configuration: configuration,
            elementRenderers: elementRenderers,
            fonts: fonts,
            blockQuoteStyle: environmentValues.blockQuoteStyle,
            codeBlockStyle: environmentValues.codeBlockStyle,
            tableStyle: environmentValues.markdownTableStyle
        )
    }

    package init(
        configuration: MarkdownPresentation.MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration],
        fonts: AnyMarkdownFontGroup,
        blockQuoteStyle: any MarkdownBlockQuoteStyle,
        codeBlockStyle: any MarkdownCodeBlockStyle,
        tableStyle: any MarkdownTableStyle
    ) {
        self.configuration = configuration
        self.elementRenderers = elementRenderers
        self.fonts = fonts
        self.blockQuoteStyle = blockQuoteStyle
        self.codeBlockStyle = codeBlockStyle
        self.tableStyle = tableStyle
    }

    package func makeTextContent(for markup: any Markup) -> TextContent {
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

    package func visitDocument(_ document: Document) -> TextContent {
        return render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeNodes(for: document)
        )
    }

    package func defaultVisit(_ markup: Markdown.Markup) -> TextContent {
        descendInto(markup)
    }

    package func visitParagraph(_ paragraph: Paragraph) -> TextContent {
        paragraphTextContent(descendInto(paragraph))
    }

    package func visitHeading(_ heading: Heading) -> TextContent {
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

    package func visitText(_ text: Markdown.Text) -> TextContent {
        let plainText = text.plainText
        #if canImport(LaTeXSwiftUI)
        if configuration.math.shouldRender,
           let inlineMathStorage = configuration.math.inlineMathStorage {
            return inlineMathTextContent(
                text: plainText,
                inlineMathStorage: inlineMathStorage
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

        if let linkRenderer = linkRenderer(for: url) {
            return MarkdownTextEmbeddingViewFactory.makeTextContent(
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
                .markdownTextAttachmentEnvironment(from: self)
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

    package func visitOrderedList(_ orderedList: OrderedList) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeNodes(for: orderedList)
        )
    }

    package func visitUnorderedList(_ unorderedList: UnorderedList) -> TextContent {
        render(
            MarkdownTextSemanticBuilder(configuration: configuration)
                .makeNodes(for: unorderedList)
        )
    }

    package func visitListItem(_ listItem: ListItem) -> TextContent {
        return renderListItem(
            MarkdownTextSemanticListItem(
                marker: listMarker(for: listItem),
                sourceMarkup: listItem
            ),
            listDepth: (listItem.parent as? ListItemContainer)?.listDepth ?? 0
        )
    }
}

extension MDTextConverter {
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
