import Markdown
import SwiftUI

extension Renderer {
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> AnyView {
        let renderer = BlockDirectiveRenderer.shared
        
        var handler: (any BlockDirectiveDisplayable)?
        renderer.blockDirectiveHandlers.forEach { name, value in
            if name.lowercased() == blockDirective.name.lowercased() {
                handler = value
            }
        }
        
        let args = blockDirective
            .argumentText
            .parseNameValueArguments()
            .map {
                BlockDirectiveArgument($0)
            }
        
        var subviews = [AnyView]()
        for child in blockDirective.children {
            subviews.append(AnyView(visit(child)))
        }
        let innerMarkdownView = AnyView(
            FlexibleStack {
                ForEach(subviews.indices, id: \.self) {
                    subviews[$0]
                }
            }
        )
        return renderer.loadBlockDirective(handler: handler, args: args, innerMarkdownView: innerMarkdownView)
    }
}
