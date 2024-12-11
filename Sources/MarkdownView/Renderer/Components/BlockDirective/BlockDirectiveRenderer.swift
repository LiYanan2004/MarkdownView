import SwiftUI
import Markdown

@dynamicMemberLookup
class BlockDirectiveRenderer: @unchecked Sendable {
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
            return provider.makeView(
                arguments: args, text: text
            ).eraseToAnyView()
        }
        return nil
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<[String : any BlockDirectiveDisplayable], T>) -> T {
        providers[keyPath: keyPath]
    }
}

extension BlockDirectiveRenderer: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(providers.keys.map(\.self))
    }
    
    static func == (lhs: BlockDirectiveRenderer, rhs: BlockDirectiveRenderer) -> Bool {
        lhs.providers.keys == rhs.providers.keys
    }
}
