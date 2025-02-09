import SwiftUI
import Markdown

/// A view to render markdown text.
public struct MarkdownView: View {
    private var _parsedContent: ParsedMarkdownContent
    
    @State private var viewSize = CGSize.zero
    @Environment(\.markdownRendererConfiguration) private var configuration
    
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
        let configuration = configuration
            .with(\.preferredBaseURL, configuration.preferredBaseURL ?? _parsedContent.raw.source)
        
        MarkdownViewRenderer(configuration: configuration)
            .representedView(for: _parsedContent.document)
            .markdownViewLayout(role: configuration.role)
            .sizeOfView($viewSize)
            .containerSize(viewSize)
            .font(configuration.fontGroup.body)
    }
}
