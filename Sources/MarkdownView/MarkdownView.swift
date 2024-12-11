import SwiftUI
import Markdown

/// A view to render markdown text.
public struct MarkdownView: View {
    @Binding private var text: String
    var baseURL: URL?

    @State private var viewSize = CGSize.zero
    @State private var configuration = RendererConfiguration()
    
    @StateObject private var viewProvider = MarkdownViewProvider()
    
    /// Parse the Markdown and render it as a single `View`.
    /// - Parameters:
    ///   - text: A Binding Text that can be modified.
    ///   - baseURL: A path where the images will load from.
    public init(text: Binding<String>, baseURL: URL? = nil) {
        _text = text
        if let baseURL {
            self.baseURL = baseURL
        }
    }
    
    /// Parse the Markdown and render it as a single view.
    /// - Parameters:
    ///   - text: Markdown Text.
    ///   - baseURL: A path where the images will load from.
    public init(text: String, baseURL: URL? = nil) {
        _text = .constant(text)
        if let baseURL {
            self.baseURL = baseURL
        }
    }
    
    public var body: some View {
        ScrollViewReader { scrollProxy in
            viewProvider.content
                .markdownViewLayout(role: configuration.role)
                .onAppear {
                    ScrollProxyRef.shared.setProxy(scrollProxy)
                }
        }
        .sizeOfView($viewSize)
        .containerSize(viewSize)
        .modifier(CodeHighlighterUpdater())
        .font(configuration.fontGroup.body)
        .task(id: text) {
            viewProvider.updateMarkdownView(markdown: text)
        }
        .task(id: configuration) {
            viewProvider.updateRenderConfiguration(configuration)
        }
        .task(id: baseURL) {
            guard let baseURL else { return }
            configuration.imageRenderer.updateBaseURL(baseURL)
        }
    }
}
