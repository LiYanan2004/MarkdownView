import SwiftUI
import Markdown

public struct MarkdownView: View {
    @Binding private var text: String
    @StateObject var imageCacheController = ImageCacheController()
    var imageHandlerConfiguration = ImageHandlerConfiguration()
    var directiveBlockConfiguration = DirectiveBlockConfiguration()
    var lazyLoad = true
    
    /// Parse the Markdown and render it as a single `View`
    /// - Parameters:
    ///   - text: A Binding Text that can be modified
    ///   - baseURL: A path where the images will load from
    public init(text: Binding<String>, baseURL: URL? = nil) {
        _text = text
        if let baseURL {
            imageHandlerConfiguration = ImageHandlerConfiguration(baseURL: baseURL)
        }
    }
    
    /// Parse the Markdown and render it as a single `View`
    /// - Parameters:
    ///   - text: Markdown Text.
    ///   - baseURL: A path where the images will load from
    public init(_ text: String, baseURL: URL? = nil) {
        _text = .constant(text)
        if let baseURL {
            imageHandlerConfiguration = ImageHandlerConfiguration(baseURL: baseURL)
        }
    }
    
    public var body: some View {
        let document = Document(parsing: text, options: .parseBlockDirectives)
        
        var renderer = Renderer(configuration: configuration)
        renderer.RepresentedView(from: document)
    }
}
