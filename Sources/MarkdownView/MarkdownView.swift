import SwiftUI
import Markdown

/// A view that displays read-only Markdown content.
public struct MarkdownView: View {
    private var content: MarkdownContent
    
    @State private var viewSize = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.displayScale) private var displayScale
    
    @Environment(\.markdownViewStyle) private var markdownViewStyle
    @Environment(\.markdownRendererConfiguration) private var _configuration
    private var configuration: MarkdownRenderConfiguration {
        _configuration
            .with(\.colorScheme, colorScheme)
            .with(\.displayScale, displayScale)
            .with(\.preferredBaseURL, _configuration.preferredBaseURL ?? content.raw.source)
    }
    
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
            .makeBody(configuration: MarkdownViewStyleConfiguration {
                MarkdownViewRenderer(configuration: configuration)
                    .render(content.document)
            })
            .erasedToAnyView()
            .sizeOfView($viewSize)
            .containerSize(viewSize)
            .font(configuration.fontGroup.body)
            .transformEnvironment(\.markdownRendererConfiguration) { configuration in
                configuration.colorScheme = colorScheme
            }
    }
}
