import SwiftUI
import Markdown

/// A view to render markdown text.
public struct MarkdownView: View {
    private var _parsedContent: ParsedMarkdownContent
    
    @State private var viewSize = CGSize.zero
    @Environment(\.colorScheme) private var colorScheme
    
    @Environment(\.markdownRendererConfiguration) private var _configuration
    private var configuration: MarkdownRenderConfiguration {
        _configuration
            .with(\.colorScheme, colorScheme)
            .with(\.preferredBaseURL, _configuration.preferredBaseURL ?? _parsedContent.raw.source)
    }
    
    public init(_ text: String) {
        self._parsedContent = ParsedMarkdownContent(
            raw: .plainText(text)
        )
    }
    
    public init(_ url: URL) {
        self._parsedContent = ParsedMarkdownContent(
            raw: .url(url)
        )
    }
    
    public init(_ content: ParsedMarkdownContent) {
        self._parsedContent = content
    }
    
    public var body: some View {
        MarkdownViewRenderer(configuration: configuration)
            .render(_parsedContent.document)
            .markdownViewLayout(role: configuration.role)
            .sizeOfView($viewSize)
            .containerSize(viewSize)
            .font(configuration.fontGroup.body)
            .transformEnvironment(\.markdownRendererConfiguration) { configuration in
                configuration.colorScheme = colorScheme
            }
    }
}
