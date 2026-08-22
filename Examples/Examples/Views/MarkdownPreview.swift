//
//  MarkdownPreview.swift
//  Examples
//

import MarkdownView
import SwiftUI

struct MarkdownPreview: View {
    var source: StreamingMarkdownSource
    var rendererKind: MarkdownRendererKind
    var animation: any StreamingTextAnimation

    var body: some View {
        ScrollView {
            renderedContent
                .scenePadding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .defaultScrollAnchor(.bottom)
        .markdownMathRenderingEnabled()
        .markdownLinksUnderlined()
        .markdownBaseURL(Self.showcaseBaseURL)
        .markdownBlockQuoteStyle(ShowcaseBlockQuoteStyle())
        .markdownElementRenderer(.link(ShowcaseLinkRenderer(), urlScheme: "sample"))
        .markdownElementRenderer(.image(ShowcaseSymbolImageRenderer(), urlScheme: "symbol"))
        .markdownElementRenderer(.blockDirective(ShowcaseCalloutRenderer(), name: "callout"))
        #if os(iOS) || os(macOS)
        .textSelection(.enabled)
        #endif
    }

    private var renderedContent: some View {
        StreamingMarkdownReader(source) { parseResult in
            switch rendererKind {
                #if os(iOS) || os(macOS)
                case .markdownText:
                    MarkdownText(parseResult)
                #endif
                case .markdownView:
                    MarkdownView(parseResult)
            }
        }
        .markdownStreamingAnimation(animation)
    }

    private static let showcaseBaseURL = URL(string: "https://developer.apple.com")!
}
