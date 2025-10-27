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
