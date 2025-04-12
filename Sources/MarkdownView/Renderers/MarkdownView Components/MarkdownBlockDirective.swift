//
//  MarkdownBlockDirective.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

struct MarkdownBlockDirective: View {
    var blockDirective: BlockDirective
    private var blockDirectiveRendererConfiguration: BlockDirectiveRendererConfiguration {
        BlockDirectiveRendererConfiguration(
            text: blockDirective
                .children
                .compactMap { $0.format() }
                .joined(),
            arguments: blockDirective
                .argumentText
                .parseNameValueArguments()
                .map { BlockDirectiveRendererConfiguration.Argument($0) }
        )
    }
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        if let provider = BlockDirectiveRenderers.named(blockDirective.name) {
            provider
                .makeBody(configuration: blockDirectiveRendererConfiguration)
                .erasedToAnyView()
        } else {
            CmarkNodeVisitor(configuration: configuration)
                .descendInto(blockDirective)
        }
    }
}
