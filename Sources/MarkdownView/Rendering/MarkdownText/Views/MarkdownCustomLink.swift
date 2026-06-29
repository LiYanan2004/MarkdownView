//
//  MarkdownCustomLink.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/18.
//

#if canImport(RichText)

import Markdown
import SwiftUI

struct MarkdownCustomLink: View {
    var link: Markdown.Link
    var url: URL
    var renderer: any MarkdownLinkRenderer
    var configuration: MarkdownRendererConfiguration
    var elementRenderers: [MarkdownElementRendererRegistration]
    @Environment(\.markdownMathContext) private var mathContext

    var body: some View {
        let tintColor = configuration.tintColors[.link, default: .accentColor]
        let viewRenderer = MarkdownViewRenderer(
            configuration: configuration,
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
        let label = viewRenderer
            .makeBody(forChildrenOf: link)
            .tint(tintColor)
            .underline(configuration.underlineLinks)
            .erasedToAnyView()

        renderer
            .makeBody(
                configuration: MarkdownLinkRendererConfiguration(
                    url: url,
                    label: label
                )
            )
            .erasedToAnyView()
    }
}

#endif
