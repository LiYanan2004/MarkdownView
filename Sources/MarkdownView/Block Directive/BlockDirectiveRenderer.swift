import SwiftUI
import Markdown

class BlockDirectiveRenderer {
    /// All handlers which have been added.
    var blockDirectiveHandlers: [String : any BlockDirectiveDisplayable] = [:]
    
    /// Add custom handler for block directive .
    /// - Parameters:
    ///   - handler: Represention of the block directive.
    ///   - name: The name of wrapper.
    func addHandler(_ handler: some BlockDirectiveDisplayable, for name: String) {
        blockDirectiveHandlers[name] = handler
    }
    
    func loadBlockDirective(
        handler: (any BlockDirectiveDisplayable)?,
        args: [BlockDirectiveArgument],
        innerMarkdownView: AnyView
    ) -> AnyView {
        if let handler {
            return AnyView(handler.makeView(arguments: args, innerMarkdownView: innerMarkdownView))
        } else {
            return innerMarkdownView
        }
    }
}

extension BlockDirectiveRenderer {
    static var shared: BlockDirectiveRenderer = BlockDirectiveRenderer()
}
