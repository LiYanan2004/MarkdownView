//
//  MarkdownTextEmbeddingViewFactory.swift
//  MarkdownView
//
//  Created by Codex on 2026/6/17.
//

#if canImport(RichText)

import RichText
import SwiftUI

enum MarkdownTextEmbeddingViewFactory {
    @MainActor
    static func makeTextContent(
        id: MarkdownTextInlineViewIdentifier,
        replacement: AttributedString?,
        componentSpacing: CGFloat,
        sizing: HostedAttachmentSizing = .fittingLineFragment,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> TextContent {
        let attributes = paragraphAttributes(componentSpacing: componentSpacing)

        return TextContent {
            InlineView(id: id, replacement: replacement, sizing: sizing) {
                content()
            }
            .textContent
            .mergingAttributes(attributes)
        }
    }

    private static func paragraphAttributes(componentSpacing: CGFloat) -> AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = componentSpacing

        return AttributeContainer([
            .paragraphStyle: paragraphStyle as NSParagraphStyle
        ])
    }
}

#endif
