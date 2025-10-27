//
//  MarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

@preconcurrency
@MainActor
protocol MarkdownViewRenderer {
    associatedtype Body: SwiftUI.View
    
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> Body
}

extension MarkdownViewRenderer {
    internal func parseOptions(for configuration: MarkdownRendererConfiguration) -> ParseOptions {
        var options = ParseOptions()
        
        if !configuration.allowedBlockDirectiveRenderers.isEmpty {
            options.insert(.parseBlockDirectives)
        }
        
        return options
    }
}
