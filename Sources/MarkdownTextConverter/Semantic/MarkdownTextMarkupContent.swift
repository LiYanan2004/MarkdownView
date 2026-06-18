#if canImport(RichText)

import Markdown
import MarkdownPresentation
import MarkdownRenderingEssentials
import RichText
import SwiftUI

struct MarkdownTextMarkupContent: View {
    private var markups: [any Markup]

    init(markup: any Markup) {
        markups = [markup]
    }

    init(childrenOf markup: any Markup) {
        markups = Array(markup.children)
    }

    @Environment(\.markdownRendererConfiguration) private var rendererConfiguration
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownFontGroup) private var fonts
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    @Environment(\.markdownTableStyle) private var tableStyle

    var body: some View {
        let converter = MDTextConverter(
            configuration: rendererConfiguration,
            elementRenderers: elementRenderers,
            fonts: fonts,
            blockQuoteStyle: blockQuoteStyle,
            codeBlockStyle: codeBlockStyle,
            tableStyle: tableStyle
        )

        TextView {
            converter.makeTextContent(for: markups)
        }
    }
}

#endif
