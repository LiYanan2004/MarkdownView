import Markdown
import SwiftUI

extension MarkdownViewRenderer {
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
        var provider: (any BlockDirectiveDisplayable)?
        configuration.blockDirectiveRenderer.providers.forEach { name, value in
            if name.localizedLowercase == blockDirective.name.localizedLowercase {
                provider = value
            }
        }
        
        let args = blockDirective
            .argumentText
            .parseNameValueArguments()
            .map { BlockDirectiveArgument($0) }
        
        if let customView = configuration.blockDirectiveRenderer.loadBlockDirective(
            provider: provider,
            args: args,
            text: blockDirective.format(options: .default)
        ) {
            return Result { customView }
        }
        
        var contents = [Result]()
        for child in blockDirective.children {
            contents.append(visit(child))
        }
        return Result(contents)
    }
}
