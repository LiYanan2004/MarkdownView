import SwiftUI
import Markdown
import Combine

/// A view to render markdown text.
public struct MarkdownView: View {
    @Binding private var text: String

    @State private var viewSize = CGSize.zero
    
    @Environment(\.lineSpacing) private var lineSpacing
    @Environment(\.markdownFont) private var fontProvider
    @Environment(\.markdownViewRole) private var role
    @Environment(\.codeHighlighterTheme) private var codeHighlighterTheme
    @Environment(\.inlineCodeBlockTint) private var inlineTintColor
    @Environment(\.blockQuoteTint) private var blockQuoteTintColor
    
    // Update content 0.3s after the user stops entering.
    @StateObject private var contentUpdater = ContentUpdater()
    @State private var representedView = AnyView(Color.black.opacity(0.001)) // RenderedView
    
    /// Parse the Markdown and render it as a single `View`.
    /// - Parameters:
    ///   - text: A Binding Text that can be modified.
    ///   - baseURL: A path where the images will load from.
    public init(text: Binding<String>, baseURL: URL? = nil) {
        _text = text
        if let baseURL {
            ImageRenderer.shared.baseURL = baseURL
        }
    }
    
    /// Parse the Markdown and render it as a single view.
    /// - Parameters:
    ///   - text: Markdown Text.
    ///   - baseURL: A path where the images will load from.
    public init(text: String, baseURL: URL? = nil) {
        _text = .constant(text)
        if let baseURL {
            ImageRenderer.shared.baseURL = baseURL
        }
    }
    
    public var body: some View {
        ZStack {
            switch configuration.role {
            case .normal: representedView
            case .editor:
                representedView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .sizeOfView($viewSize)
        .containerSize(viewSize)
        // Set default font.
        .font(fontProvider.body)
        // Push current text, waiting for next update.
        .onChange(of: text, perform: contentUpdater.push(_:))
        // Load view immediately after the first launch.
        // Receive configuration changes and reload MarkdownView to fit.
        .task(id: configuration) { makeView(text: text) }
        // Received a debouncedText, we need to reload MarkdownView.
        .onReceive(contentUpdater.textUpdater, perform: makeView(text:))
    }
    
    private func makeView(text: String) {
        Task.detached {
            let config = await self.configuration
            var renderer = Renderer(
                text: text,
                configuration: config,
                interactiveEditHandler: { text in
                    Task { @MainActor in
                        self.text = text
                        self.makeView(text: text)
                    }
                }
            )
            let parseBD = !BlockDirectiveRenderer.shared.blockDirectiveProviders.isEmpty
            let view = renderer.representedView(parseBlockDirectives: parseBD)
            Task { @MainActor in
                representedView = view
            }
        }
    }
}

extension MarkdownView {
    var configuration: RendererConfiguration {
        RendererConfiguration(
            role: role,
            lineSpacing: lineSpacing,
            inlineCodeTintColor: inlineTintColor,
            blockQuoteTintColor: blockQuoteTintColor,
            fontProvider: fontProvider,
            codeBlockTheme: codeHighlighterTheme
        )
    }
}
