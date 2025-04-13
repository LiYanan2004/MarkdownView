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
    @Environment(\.self) private var environments
    
    var body: some View {
        if let provider = BlockDirectiveRenderers.named(blockDirective.name) {
            let configuration = BlockDirectiveRendererConfiguration(
                wrappedString: blockDirective
                    .children
                    .compactMap { $0.format() }
                    .joined(separator: "\n"),
                arguments: blockDirective
                    .argumentText
                    .parseNameValueArguments()
                    .map { BlockDirectiveRendererConfiguration.Argument($0) },
                environments: environments
            )
            provider
                .makeBody(configuration: configuration)
                .erasedToAnyView()
        } else {
            @Environment(\.markdownRendererConfiguration) var configuration
            CmarkNodeVisitor(configuration: configuration)
                .descendInto(blockDirective)
        }
    }
}
