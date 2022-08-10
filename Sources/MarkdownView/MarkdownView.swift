import SwiftUI
import Markdown

public struct MarkdownView: View {
    @Binding private var text: String
    private var imageHandlerConfiguration = ImageHandlerConfiguration()
    
    public init(text: Binding<String>) {
        _text = text
    }
    
    public init(_ text: String) {
        _text = .constant(text)
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
