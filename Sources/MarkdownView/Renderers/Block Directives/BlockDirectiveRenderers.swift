import SwiftUI
import Markdown

@dynamicMemberLookup
class BlockDirectiveRenderers: @unchecked Sendable {
    static let shared: BlockDirectiveRenderers = .init()
    
    private init() { }
    
    /// All providers which have been added.
    private var renderers: [String : any BlockDirectiveRenderer] = [:]

    /// Add custom provider for block directive .
    /// - Parameters:
    ///   - renderer: Represention of the block directive.
    ///   - name: The name of wrapper.
    func addRenderer(_ renderer: some BlockDirectiveRenderer, for name: String) {
        renderers[name] = renderer
    }
    
    static func named(_ name: String) -> (any BlockDirectiveRenderer)? {
        if let renderer = BlockDirectiveRenderers.shared.renderers[name] {
            return renderer
        }
        
        let lowercaseName = name.lowercased()
        return BlockDirectiveRenderers.shared
            .renderers
            .first(where: { $0.key.lowercased() == lowercaseName })?
            .value
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<[String : any BlockDirectiveRenderer], T>) -> T {
        renderers[keyPath: keyPath]
    }
}
