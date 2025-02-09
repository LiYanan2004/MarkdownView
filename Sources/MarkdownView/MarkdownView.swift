import SwiftUI
import Markdown

/// A view to render markdown text.
public struct MarkdownView: View {
    private var content: MarkdownContent

    @State private var viewSize = CGSize.zero
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    public init(_ text: String) {
        content = .plainText(text)
    }
    
    public init(_ url: URL) {
        content = .url(url)
    }
    
    public var body: some View {
        let configuration = configuration
            .with(\.preferredBaseURL, configuration.preferredBaseURL ?? content.source)
        
        MarkdownViewRenderer(configuration: configuration)
            .representedView(for: document)
            .markdownViewLayout(role: configuration.role)
            .sizeOfView($viewSize)
            .containerSize(viewSize)
            .font(configuration.fontGroup.body)
    }
    
    private var document: Document {
        var options = ParseOptions()
        if !configuration.blockDirectiveRenderer.isEmpty {
            options.insert(.parseBlockDirectives)
        }
        
        return Document(
            parsing: content.text,
            source: content.source,
            options: options
        )
    }
}
