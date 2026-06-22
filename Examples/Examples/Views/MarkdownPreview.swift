//
//  MarkdownPreview.swift
//  Examples
//

import MarkdownView
import SwiftUI
internal import RichText

struct MarkdownPreview: View {
    var markdownText: String
    var rendererKind: MarkdownRendererKind

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

    @ViewBuilder
    private var renderedContent: some View {
        StreamingMarkdownReader(markdownText) { doc in
            switch rendererKind {
            #if os(iOS) || os(macOS)
            case .markdownText:
                MarkdownText(doc)
            #endif
            case .markdownView:
                MarkdownView(doc)
            }
        }
    }

    private static let showcaseBaseURL = URL(string: "https://developer.apple.com")!
}

#Preview {
    MarkdownPreview(
        markdownText: ExampleMarkdown.showcase,
        rendererKind: .markdownView
    )
}

#if os(iOS) || os(macOS)
#Preview("MarkdownText") {
    MarkdownPreview(
        markdownText: ExampleMarkdown.showcase,
        rendererKind: .markdownText
    )
}
#endif
