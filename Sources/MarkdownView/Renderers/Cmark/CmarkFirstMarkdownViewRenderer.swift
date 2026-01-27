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
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        var parseOptions = ParseOptions()
        if !configuration.allowedBlockDirectiveRenderers.isEmpty {
            parseOptions.insert(.parseBlockDirectives)
        }
        
        return CmarkNodeVisitor(configuration: configuration)
            .makeBody(for: content.document(options: parseOptions))
    }
}

#if canImport(RichText)
import RichText

@available(iOS 26, macOS 26, *)
struct TextViewViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        var parseOptions = ParseOptions()
        if !configuration.allowedBlockDirectiveRenderers.isEmpty {
            parseOptions.insert(.parseBlockDirectives)
        }
        
        let textContent = CmarkTextContentVisitor(configuration: configuration)
            .makeTextContent(for: content.document(options: parseOptions))
        return TextView {
            textContent
        }
    }
}
#endif
