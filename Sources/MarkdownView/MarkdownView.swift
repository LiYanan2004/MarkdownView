import SwiftUI
import Markdown

public struct MarkdownView: View {
    @Binding private var text: String
    private var imageHandlerConfiguration = ImageHandlerConfiguration()
    
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
    
    public var body: some View {
        let document = Document(parsing: text)
        var renderer = MarkdownRenderer(imageHandlerConfiguration: imageHandlerConfiguration)
        
        renderer.RepresentedView(from: document)
    }
    
    public func imageHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        result.imageHandlerConfiguration.addHandler(handler, forURLScheme: urlScheme)
        
        return result
    }
}
