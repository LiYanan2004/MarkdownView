import SwiftUI
import Markdown

class BlockDirectiveRenderer {
    /// All providers which have been added.
    var blockDirectiveProviders: [String : any BlockDirectiveDisplayable] = [:]
    
    /// Add custom provider for block directive .
    /// - Parameters:
    ///   - provider: Represention of the block directive.
    ///   - name: The name of wrapper.
    func addProvider(_ provider: some BlockDirectiveDisplayable, for name: String) {
        blockDirectiveProviders[name] = provider
    }
    
    func loadBlockDirective(
        provider: (any BlockDirectiveDisplayable)?,
        args: [BlockDirectiveArgument],
        innerMarkdownView: AnyView
    ) -> AnyView {
        if let provider {
            return AnyView(provider.makeView(arguments: args, innerMarkdownView: innerMarkdownView))
        } else {
            return innerMarkdownView
        }
    }
}

extension BlockDirectiveRenderer {
    static var shared: BlockDirectiveRenderer = BlockDirectiveRenderer()
}

// MARK: - Display Directive Blocks

extension MarkdownView {
    /// Adds your custom block directive provider.
    ///
    /// - parameters:
    ///     - provider: The provider you have created to handle block displaying.
    ///     - name: The name of the  block directive.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this provider multiple times if you have multiple providers.
    public func blockDirectiveProvider(
        _ provider: some BlockDirectiveDisplayable, for name: String
    ) -> MarkdownView {
        BlockDirectiveRenderer.shared.addProvider(provider, for: name)
        return self
    }
}
