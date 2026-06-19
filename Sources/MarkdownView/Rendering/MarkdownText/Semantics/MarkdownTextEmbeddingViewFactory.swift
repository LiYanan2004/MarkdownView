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
        replacement: AttributedString?,
        componentSpacing: CGFloat,
        sizing: HostedAttachmentSizing = .fittingLineFragment,
        @ViewBuilder content: @MainActor @escaping () -> some View
    ) -> TextContent {
        let attributes = paragraphAttributes(componentSpacing: componentSpacing)

        return TextContent {
            InlineView(replacement: replacement, sizing: sizing) {
                content()
                    .fixedSize(horizontal: false, vertical: true)
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
