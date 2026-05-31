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
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var customRenderers
    
    var body: some View {
        if let renderer = blockDirectiveRenderer(for: blockDirective.name) {
            let configuration = BlockDirectiveRendererConfiguration(
                wrappedString: blockDirective
                    .children
                    .compactMap { $0.format() }
                    .joined(separator: "\n"),
                arguments: blockDirective
                    .argumentText
                    .parseNameValueArguments()
                    .map { BlockDirectiveRendererConfiguration.Argument($0) }
            )
            renderer
                .makeBody(configuration: configuration)
                .erasedToAnyView()
        } else {
            CmarkNodeVisitor(configuration: configuration, customRenderers: customRenderers)
                .descendInto(blockDirective)
        }
    }

    private func blockDirectiveRenderer(for name: String) -> (any BlockDirectiveRenderer)? {
        customRenderers
            .compactMap(\.blockDirective)
            .first(where: { $0.name == name })?
            .renderer
    }
}
