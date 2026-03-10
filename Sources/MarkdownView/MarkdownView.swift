import SwiftUI
import Markdown

/// A view that renders markdown content.
public struct MarkdownView: View {
    @ObservedObject private var content: MarkdownContent
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownViewRenderer) private var renderer
    
    /// Creates a view that renders given markdown string.
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        self.content = MarkdownContent(text)
    }
    
    /// Creates a view that renders the markdown from a local file at given url.
    /// - Parameter url: The url to the markdown file to render.
    public init(_ url: URL) {
        self.content =  MarkdownContent(url)
    }
    
    /// Creates an instance that renders from a ``MarkdownContent`` .
    /// - Parameter content: The ``MarkdownContent`` to render.
    public init(_ content: MarkdownContent) {
        self.content = content
    }
    
    public var body: some View {
        renderer
            .makeBody(content: content, configuration: configuration)
            .erasedToAnyView()
            .font(configuration.fonts[.body] ?? Font.body)
    }
}

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        MarkdownView("Hello **World**")
            .markdownTextSelection(.enabled)
    }
    #if os(macOS) || os(iOS)
    .textSelection(.enabled)
    #endif
    .padding()
}
