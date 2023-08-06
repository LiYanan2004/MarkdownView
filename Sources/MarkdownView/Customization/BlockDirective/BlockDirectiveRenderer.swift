import SwiftUI
import Markdown

class BlockDirectiveRenderer {
    /// All providers which have been added.
    var providers: [String : any BlockDirectiveDisplayable] = [:]
    
    /// Add custom provider for block directive .
    /// - Parameters:
    ///   - provider: Represention of the block directive.
    ///   - name: The name of wrapper.
    func addProvider(_ provider: some BlockDirectiveDisplayable, for name: String) {
        providers[name] = provider
    }
    
    func loadBlockDirective(
        provider: (any BlockDirectiveDisplayable)?,
        args: [BlockDirectiveArgument],
        text: String
    ) -> AnyView? {
        if let provider {
            return AnyView(provider.makeView(arguments: args, text: text))
        }
        return nil
    }
}
