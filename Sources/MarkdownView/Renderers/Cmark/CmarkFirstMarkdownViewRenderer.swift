//
//  CmarkFirstMarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

struct CmarkFirstMarkdownViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        return CmarkNodeVisitor(
            configuration: configuration,
            elementRenderers: elementRenderers
        )
            .makeBody(for: content.document(options: parseOptions(for: elementRenderers)))
    }
}

#if canImport(RichText)
import RichText

@available(iOS 26, macOS 26, *)
struct TextViewViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        let textContent = CmarkTextContentVisitor(configuration: configuration)
            .makeTextContent(for: content.document(options: parseOptions(for: elementRenderers)))
        return TextView {
            textContent
        }
    }
}
#endif
