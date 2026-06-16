//
//  MarkdownTextAttachmentRenderer.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/15.
//

#if canImport(RichText)
import Foundation
import Markdown
import RichText

public struct MarkdownTextAttachmentContext {
    public var attachment: MarkdownTextAttachment
    public var replacement: AttributedString?
    public var appendsLineBreak: Bool

    public init(
        attachment: MarkdownTextAttachment,
        replacement: AttributedString?,
        appendsLineBreak: Bool
    ) {
        self.attachment = attachment
        self.replacement = replacement
        self.appendsLineBreak = appendsLineBreak
    }
}

@preconcurrency
@MainActor
public protocol MarkdownTextAttachmentRenderer {
    func makeBlockQuoteTextContent(
        for blockQuote: BlockQuote,
        context: MarkdownTextAttachmentContext
    ) -> TextContent

    func makeBlockDirectiveTextContent(
        for blockDirective: BlockDirective,
        context: MarkdownTextAttachmentContext
    ) -> TextContent

    func makeImageTextContent(
        for image: Markdown.Image,
        context: MarkdownTextAttachmentContext
    ) -> TextContent

    func makeCodeBlockTextContent(
        for codeBlock: CodeBlock,
        context: MarkdownTextAttachmentContext
    ) -> TextContent

    func makeHTMLBlockTextContent(
        for htmlBlock: HTMLBlock,
        context: MarkdownTextAttachmentContext
    ) -> TextContent

    func makeTableTextContent(
        for table: Markdown.Table,
        context: MarkdownTextAttachmentContext
    ) -> TextContent
}

public extension MarkdownTextAttachmentRenderer {
    func makeBlockDirectiveTextContent(
        for blockDirective: BlockDirective,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        context.fallbackTextContent
    }

    func makeImageTextContent(
        for image: Markdown.Image,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        context.fallbackTextContent
    }

    func makeHTMLBlockTextContent(
        for htmlBlock: HTMLBlock,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        context.fallbackTextContent
    }

    func makeTableTextContent(
        for table: Markdown.Table,
        context: MarkdownTextAttachmentContext
    ) -> TextContent {
        context.fallbackTextContent
    }
}

public extension MarkdownTextAttachmentContext {
    @MainActor
    var fallbackTextContent: TextContent {
        var textContent = replacement.map {
            TextContent(.attributedString($0))
        } ?? TextContent([])

        if appendsLineBreak {
            textContent += LineBreak().textContent
        }

        return textContent
    }
}
#endif
