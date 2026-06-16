//
//  MarkdownBlockDirective.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

package struct MarkdownBlockDirective: View {
    package var blockDirective: BlockDirective
    private var fallbackContent: AnyView
    @Environment(\.markdownElementRenderers) private var elementRenderers

    package init(
        blockDirective: BlockDirective,
        fallbackContent: some View
    ) {
        self.blockDirective = blockDirective
        self.fallbackContent = AnyView(fallbackContent)
    }
    
    package var body: some View {
        if let renderer = blockDirectiveRenderer(for: blockDirective.name) {
            let configuration = MarkdownBlockDirectiveRendererConfiguration(
                wrappedString: blockDirective
                    .children
                    .compactMap { $0.format() }
                    .joined(separator: "\n"),
                arguments: blockDirective
                    .argumentText
                    .parseNameValueArguments()
                    .map { MarkdownBlockDirectiveRendererConfiguration.Argument($0) }
            )
            renderer
                .makeBody(configuration: configuration)
                .erasedToAnyView()
        } else {
            fallbackContent
        }
    }

    private func blockDirectiveRenderer(for name: String) -> (any MarkdownBlockDirectiveRenderer)? {
        elementRenderers
            .compactMap(\.blockDirective)
            .first(where: { $0.name == name })?
            .renderer
    }
}
