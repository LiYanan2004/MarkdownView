import SwiftUI
import Markdown

/// A view that renders markdown content.
public struct MarkdownView: View {
    @ObservedObject private var content: MarkdownContent
    
    @Environment(\.markdownFontGroup.body) private var bodyFont
    @Environment(\.markdownRendererConfiguration) private var configuration
    
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
        _renderedBody.font(bodyFont)
    }
    
    @ViewBuilder
    private var _renderedBody: some View {
        if configuration.rendersMath {
            MathFirstMarkdownViewRenderer().makeBody(
                content: content,
                configuration: configuration
            )
        } else {
            CmarkFirstMarkdownViewRenderer().makeBody(
                content: content,
                configuration: configuration
            )
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        MarkdownView("Hello **World**")
    }
    #if os(macOS) || os(iOS)
    .textSelection(.enabled)
    #endif
    .padding()
}
