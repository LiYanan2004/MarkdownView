import SwiftUI
import Markdown

/// A view to render markdown text.
///
/// - note: If you want to change font size, you shoud use ``environment(_:_:)`` to modify the `dynamicTypeSize` instead of using ``font(_:)``.
///
public struct MarkdownView: View {
    @State private var containerSize = CGSize.zero
    @Binding private var text: String
    @StateObject var imageCacheController = ImageCacheController()
    var imageHandlerConfiguration = ImageHandlerConfiguration()
    var directiveBlockConfiguration = DirectiveBlockConfiguration()
    var codeBlockThemeConfiguration = CodeBlockThemeConfiguration(
        lightModeThemeName: "xcode", darkModeThemeName: "dark"
    )
    
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
        var renderer = Renderer(text: $text, withConfiguration: configuration)
        renderer.RepresentedView()
            .environment(\.containerSize, containerSize)
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ContainerMeasurement.self, value: proxy.size)
                }
            }
            .onPreferenceChange(ContainerMeasurement.self) { size in
                containerSize = size
            }
    }
}

struct ContainerMeasurement: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ContainerSize: EnvironmentKey {
    static var defaultValue = CGSize.zero
}

extension EnvironmentValues {
    var containerSize: CGSize {
        get { self[ContainerSize.self] }
        set { self[ContainerSize.self] = newValue }
    }
}
