import Markdown
import SwiftUI

extension Renderer {
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> AnyView {
        let configuration = configuration.directiveBlockConfiguration
        
        var handlerFound: MarkdownDirectiveBlockHandler?
        configuration.directiveBlockHandlers.forEach { name, handler in
            if name.lowercased() == blockDirective.name.lowercased() {
                handlerFound = handler
            }
        }
        
        var subviews = [AnyView]()
        for child in blockDirective.children {
            subviews.append(AnyView(visit(child)))
        }
        let wrappedContent: any View = {
            FlexibleLayout {
                ForEach(subviews.indices, id: \.self) {
                    subviews[$0]
                }
            }
        }()
        
        if let handlerFound {
            let arguments = blockDirective.argumentText.parseNameValueArguments().map {
                MarkdownDirectiveBlockHandler.Argument($0)
            }
            return AnyView(
                handlerFound.content(arguments, wrappedContent)
            )
        } else { return AnyView(EmptyView()) }
    }
}
