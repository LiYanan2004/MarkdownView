import SwiftUI
import Markdown

/// A view that displays read-only Markdown content.
public struct MarkdownView: View {
    private var content: MarkdownContent
    
    @State private var viewSize = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers
    @Environment(\.markdownViewStyle) private var markdownViewStyle
    @Environment(\.markdownFontGroup.body) private var bodyFont
    
    public init(_ text: String) {
        self.content = MarkdownContent(
            raw: .plainText(text)
        )
    }
    
    @_spi(WIP)
    public init(_ url: URL) {
        self.content = MarkdownContent(
            raw: .url(url)
        )
    }
    
    public init(_ content: MarkdownContent) {
        self.content = content
    }
    
    public var body: some View {
        markdownViewStyle
            .makeBody(
                configuration: MarkdownViewStyleConfiguration(body: _renderedBody)
            )
            .erasedToAnyView()
            .font(bodyFont)
    }
    
    @ViewBuilder
    private var _renderedBody: some View {
        if configuration.math.shouldRender {
            MathFirstMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration, elementRenderers: elementRenderers)
        } else {
            CmarkFirstMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration, elementRenderers: elementRenderers)
        }
    }
}
