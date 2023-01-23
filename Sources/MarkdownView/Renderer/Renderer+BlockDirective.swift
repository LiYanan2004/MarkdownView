import Markdown
import SwiftUI

extension Renderer {
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        let renderer = BlockDirectiveRenderer.shared
        
        var provider: (any BlockDirectiveDisplayable)?
        renderer.blockDirectiveProviders.forEach { name, value in
            if name.lowercased() == blockDirective.name.lowercased() {
                provider = value
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
        let BDView = renderer.loadBlockDirective(provider: provider, args: args, innerMarkdownView: innerMarkdownView)
        return Result(BDView)
    }
}
