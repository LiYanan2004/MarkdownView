//
//  MarkdownCustomLink.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/18.
//

#if canImport(RichText)

import Markdown
import SwiftUI
import MarkdownPresentation
import RichText

struct MarkdownCustomLink: View {
    var link: Markdown.Link
    var url: URL
    var renderer: any MarkdownLinkRenderer
    var configuration: MarkdownRendererConfiguration
    var elementRenderers: [MarkdownElementRendererRegistration]

    @Environment(\.markdownFontGroup) private var fonts
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    @Environment(\.markdownTableStyle) private var tableStyle

    var body: some View {
        let tintColor = configuration.tintColors[.link, default: .accentColor]
        let converter = MDTextConverter(
            configuration: configuration,
            elementRenderers: elementRenderers,
            fonts: fonts,
            blockQuoteStyle: blockQuoteStyle,
            codeBlockStyle: codeBlockStyle,
            tableStyle: tableStyle
        )
        let label = TextView {
            converter
                .descendInto(link)
                .mergingAttributes(linkLabelAttributes(tintColor: tintColor))
        }
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

    private func linkLabelAttributes(tintColor: Color) -> AttributeContainer {
        var attributes = AttributeContainer()
            .foregroundColor(tintColor)

        attributes.underlineStyle = configuration.underlineLinks ? .single : .none

        return attributes
    }
}

#endif
