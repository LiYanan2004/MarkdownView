import Markdown
import SwiftUI

extension Renderer {
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
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
        
        // TODO: Research the structure of the block directive.
        var contents = [Result]()
        for child in blockDirective.children {
            contents.append(visit(child))
        }
        let innerMarkdownView = AnyView(
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(contents.indices, id: \.self) {
                    contents[$0].content
                }
            }
        )
        let BDView = renderer.loadBlockDirective(handler: handler, args: args, innerMarkdownView: innerMarkdownView)
        return Result(BDView)
    }
}
