import SwiftUI
import Markdown
import Combine

/// A view to render markdown text.
///
/// - note: If you want to change font size, you shoud use ``environment(_:_:)`` to modify the `dynamicTypeSize` instead of using ``font(_:)`` to maintain a natural layout.
///
public struct MarkdownView: View {
    @Binding private var text: String
    
    @Environment(\.lineSpacing) var lineSpacing
    @State private var containerSize = CGSize.zero
    @StateObject var imageCacheController = ImageCacheController()
    var imageHandlerConfiguration = ImageHandlerConfiguration()
    var directiveBlockConfiguration = DirectiveBlockConfiguration()
    var codeBlockThemeConfiguration = CodeBlockThemeConfiguration(
        lightModeThemeName: "xcode", darkModeThemeName: "dark"
    )
    
    // Update content 0.3s after the user stops entering.
    @StateObject var contentUpdater = ContentUpdater()
    @State private var representedView = AnyView(EmptyView()) // MarkdownView
    @State private var isSetup = false
    
    /// Parse the Markdown and render it as a single `View`.
    /// - Parameters:
    ///   - text: A Binding Text that can be modified.
    ///   - baseURL: A path where the images will load from.
    public init(text: Binding<String>, baseURL: URL? = nil) {
        _text = text
        if let baseURL {
            imageHandlerConfiguration = ImageHandlerConfiguration(baseURL: baseURL)
        }
    }
    
    /// Parse the Markdown and render it as a single view.
    /// - Parameters:
    ///   - text: Markdown Text.
    ///   - baseURL: A path where the images will load from.
    public init(text: String, baseURL: URL? = nil) {
        _text = .constant(text)
        if let baseURL {
            imageHandlerConfiguration = ImageHandlerConfiguration(baseURL: baseURL)
        }
    }
    
    public var body: some View {
        representedView
            .environment(\.containerSize, containerSize)
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ContainerMeasurement.self, value: proxy.size)
                }
            }
            .onPreferenceChange(ContainerMeasurement.self) { containerSize = $0 }
            // Push current text, waiting for next update.
            .onChange(of: text, perform: contentUpdater.push(_:))
            // Load view immediately after the first launch.
            // Receive configuration changes and reload MarkdownView to fit.
            .task(id: configuration) { makeView(text: text) }
            // Received a debouncedText, we need to reload MarkdownView.
            .onReceive(contentUpdater.textUpdater, perform: makeView(text:))
    }
    
    private func makeView(text: String) {
        var renderer = Renderer(
            text: text,
            configuration: configuration,
            interactiveEditHandler: {
                self.text = $0
                makeView(text: $0)
            }
        )
        let view = renderer.RepresentedView()
        representedView = view
    }
}

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
