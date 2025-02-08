import Combine
import SwiftUI
import Markdown

@MainActor
class MarkdownViewProvider: ObservableObject {
    var configuration = MarkdownView.RendererConfiguration()
    @Published var content: AnyView = AnyView(EmptyView())
    @Environment(\.lineSpacing) private var lineSpacing
    
    private var relay = PassthroughSubject<String, Never>()
    private var cancallables: Set<AnyCancellable> = []
    
    init() {
        setUpTextUpdater()
    }
    
    private func setUpTextUpdater() {
        let debounce = configuration.renderingMode == .immediate ? 0.0 : 0.3
        relay
            .debounce(for: .seconds(debounce), scheduler: RunLoop.main)
            .sink { rawMarkdown in
                self.renderContent(markdown: rawMarkdown)
            }
            .store(in: &cancallables)
    }
    
    private func renderContent(markdown: String) {
        configuration.withLineSpacing(lineSpacing)
        
        var renderer = Renderer(
            text: markdown,
            configuration: configuration,
            blockDirectiveRenderer: configuration.blockDirectiveRenderer,
            imageRenderer: configuration.imageRenderer
        )
        var options = ParseOptions()
        if configuration.blockDirectiveRenderer.isEmpty {
            options.insert(.parseBlockDirectives)
        }
        self.content = renderer.representedView(options: options)
    }
    
    func updateRenderConfiguration(_ configuration: MarkdownView.RendererConfiguration) {
        self.configuration = configuration
    }
    
    func updateMarkdownView(markdown: String) {
        relay.send(markdown)
        MarkdownTextStorage.default.text = markdown
    }
}

class MarkdownTextStorage: ObservableObject {
    @MainActor static let `default` = MarkdownTextStorage()
    @Published var text: String? = nil
    
    internal init() { }
}

/// A Markdown Rendering Mode.
public enum MarkdownRenderingMode: Sendable {
    /// Immediately re-render markdown view when text changes.
    case immediate
    /// Re-render markdown view efficiently by adding a debounce to the pipeline.
    ///
    /// When input markdown text is heavy and will be modified in real time, use this mode will help you reduce CPU usage thus saving battery life.
    case optimized
}

struct MarkdownRenderingModeKey: EnvironmentKey {
    static let defaultValue: MarkdownRenderingMode = .immediate
}

/// Thread to render markdown content on.
public enum MarkdownRenderingThread: Sendable {
    /// Render & Update markdown content on main thread.
    case main
    /// Render markdown content on background thread, while updating view on main thread.
    case background
}

struct MarkdownRenderingThreadKey: EnvironmentKey {
    static let defaultValue: MarkdownRenderingThread = .background
}

extension EnvironmentValues {
    /// Markdown rendering mode
    var markdownRenderingMode: MarkdownRenderingMode {
        get { self[MarkdownRenderingModeKey.self] }
        set { self[MarkdownRenderingModeKey.self] = newValue }
    }
    
    /// Markdown rendering thread
    var markdownRenderingThread: MarkdownRenderingThread {
        get { self[MarkdownRenderingThreadKey.self] }
        set { self[MarkdownRenderingThreadKey.self] = newValue }
    }
}
