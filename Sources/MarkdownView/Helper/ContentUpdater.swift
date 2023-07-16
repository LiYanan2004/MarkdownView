import Combine
import SwiftUI

/// Update content 0.3s after the user stops entering.
class ContentUpdater: ObservableObject {
    /// Send all the changes from raw text
    private var relay = PassthroughSubject<String, Never>()
    
    /// A publisher to notify MarkdownView to update its content.
    var textUpdater: AnyPublisher<String, Never>
    
    init() {
        textUpdater = relay
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func push(_ text: String) {
        relay.send(text)
    }
}

class MarkdownTextStorage: ObservableObject {
    static var `default` = MarkdownTextStorage()
    @Published var text: String? = nil
}

/// A Markdown Rendering Mode.
public enum MarkdownRenderingMode {
    /// Immediately re-render markdown view when text changes.
    case immediate
    /// Re-render markdown view efficiently by adding a debounce to the pipeline.
    ///
    /// When input markdown text is heavy and will be modified in real time, use this mode will help you reduce CPU usage thus saving battery life.
    case optimized
}

struct MarkdownRenderingModeKey: EnvironmentKey {
    static var defaultValue: MarkdownRenderingMode = .immediate
}

extension EnvironmentValues {
    /// Markdown rendering mode
    var markdownRenderingMode: MarkdownRenderingMode {
        get { self[MarkdownRenderingModeKey.self] }
        set { self[MarkdownRenderingModeKey.self] = newValue }
    }
}

// MARK: - Markdown Rendering Mode

extension View {
    /// MarkdownView rendering mode.
    ///
    /// - Parameter renderingMode: Markdown rendering mode.
    public func markdownRenderingMode(_ renderingMode: MarkdownRenderingMode) -> some View {
        environment(\.markdownRenderingMode, renderingMode)
    }
}
