import SwiftUI
import Markdown

/// A view that renders markdown content.
public struct MarkdownView: View {
    private var content: MarkdownContent
    
    @State private var viewSize = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    
    @Environment(\.markdownViewStyle) private var markdownViewStyle
    @Environment(\.markdownFontGroup.body) private var bodyFont
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    /// Creates a view that renders given markdown string.
    ///
    /// - Parameter text: The Markdown source to render.
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
    
    /// Creates a view that renders from a ``MarkdownContent`` instance.
    ///
    /// Use this initializer when the content comes from ``MarkdownReader`` or a
    /// cached value so that multiple Markdown views can reuse the same parsed
    /// document and renderer cache.
    ///
    /// - Parameter content: The parsed Markdown to render.
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
        if configuration.rendersMath {
            MathFirstMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration)
        } else {
            CmarkFirstMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration)
        }
    }
}
