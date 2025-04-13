import SwiftUI
import Markdown

/// A view that displays read-only Markdown content.
public struct MarkdownView: View {
    private var content: MarkdownContent
    
    @State private var viewSize = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    
    @Environment(\.markdownViewStyle) private var markdownViewStyle
    @Environment(\.markdownRendererConfiguration) private var configuration
    
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
            .makeBody(configuration: MarkdownViewStyleConfiguration(body: _renderedBody))
            .erasedToAnyView()
            .font(configuration.fontGroup.body)
    }
    
    @ViewBuilder
    private var _renderedBody: some View {
        if configuration.rendersMathIfPossible {
            MathFirstMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration)
        } else {
            CmarkFirstMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration)
        }
    }
}
