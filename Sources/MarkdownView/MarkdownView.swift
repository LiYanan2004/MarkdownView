import SwiftUI
import Markdown

public struct MarkdownView: View {
    @Binding private var text: String
    var imageHandlerConfiguration = ImageHandlerConfiguration()
    var lazyLoad = true
    
    public init(text: Binding<String>, baseURL: URL? = nil) {
        _text = text
        if let baseURL {
            imageHandlerConfiguration = ImageHandlerConfiguration(baseURL: baseURL)
        }
    }
    
    public init(_ text: String, baseURL: URL? = nil) {
        _text = .constant(text)
        if let baseURL {
            imageHandlerConfiguration = ImageHandlerConfiguration(baseURL: baseURL)
        }
    }
    
    var configuration: RendererConfiguration {
        RendererConfiguration(
            imageHandlerConfiguration: imageHandlerConfiguration,
            lazyLoad: lazyLoad
        )
    }
    
    public var body: some View {
        let document = Document(parsing: text)
        
        var renderer = Renderer(configuration: configuration)
        renderer.RepresentedView(from: document)
    }
}
