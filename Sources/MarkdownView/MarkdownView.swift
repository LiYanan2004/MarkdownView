import SwiftUI
import Markdown
import Combine

/// A view to render markdown text.
public struct MarkdownView: View {
    @Binding private var text: String
    var baseURL: URL?

    @State private var viewSize = CGSize.zero
    @State private var scrollViewRef = ScrollProxyRef.shared
    
    @Environment(\.markdownRenderingMode) private var renderingMode
    @Environment(\.lineSpacing) private var lineSpacing
    @Environment(\.fontGroup) private var fontGroup
    @Environment(\.markdownViewRole) private var role
    @Environment(\.codeHighlighterTheme) private var codeHighlighterTheme
    @Environment(\.inlineCodeBlockTint) private var inlineTintColor
    @Environment(\.blockQuoteTint) private var blockQuoteTintColor
    @Environment(\.foregroundStyleGroup) private var foregroundStyleGroup
    @Environment(\.blockDirectiveRenderer) private var blockDirectiveRenderer
    @Environment(\.imageRenderer) private var imageRenderer
    
    // Update content 0.3s after the user stops entering.
    @StateObject private var contentUpdater = ContentUpdater()
    @State private var representedView = AnyView(EmptyView()) // RenderedView
    
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
            ZStack {
                switch configuration.role {
                case .normal: representedView
                case .editor:
                    representedView
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .onAppear { scrollViewRef.proxy = scrollProxy }
        }
        .sizeOfView($viewSize)
        .containerSize(viewSize)
        .updateCodeBlocksWhenColorSchemeChanges()
        .font(fontGroup.body) // Default font
        .if(renderingMode == .optimized) { content in
            content
                // Received a debouncedText, we need to reload MarkdownView.
                .onReceive(contentUpdater.textUpdater, perform: makeView(text:))
                // Push current text, waiting for next update.
                .onChange(of: text, perform: contentUpdater.push(_:))
        }
        .if(renderingMode == .immediate) { content in
            content
                // Immediately update MarkdownView when text changes.
                .onChange(of: text, perform: makeView(text:))
        }
        // Load view immediately after the first launch.
        // Receive configuration changes and reload MarkdownView to fit.
        .task(id: configuration) { makeView(text: text) }
        .task(id: baseURL) { imageRenderer.baseURL = baseURL ?? imageRenderer.baseURL }
    }
    
    private func makeView(text: String) {
        func view() -> AnyView {
            var renderer = Renderer(
                text: text,
                configuration: configuration,
                interactiveEditHandler: { text in
                    Task { @MainActor in
                        self.text = text
                        self.makeView(text: text)
                    }
                },
                blockDirectiveRenderer: blockDirectiveRenderer,
                imageRenderer: imageRenderer
            )
            let parseBD = !blockDirectiveRenderer.providers.isEmpty
            return renderer.representedView(parseBlockDirectives: parseBD)
        }
        
        representedView = view()
        MarkdownTextStorage.default.text = text
    }
}

extension MarkdownView {
    var configuration: RendererConfiguration {
        RendererConfiguration(
            role: role,
            lineSpacing: lineSpacing,
            inlineCodeTintColor: inlineTintColor,
            blockQuoteTintColor: blockQuoteTintColor,
            fontGroup: fontGroup,
            foregroundStyleGroup: foregroundStyleGroup,
            codeBlockTheme: codeHighlighterTheme
        )
    }
}
