import Foundation
import SwiftUI

class MarkdownLinkRenderers: @unchecked Sendable {
    static let shared: MarkdownLinkRenderers = .init()
    
    private init() { }
    
    private(set) var renderers: [String: any MarkdownLinkRenderer] = [:]
    
    func addRenderer(
        _ renderer: some MarkdownLinkRenderer,
        forURLScheme urlScheme: String
    ) {
        renderers[urlScheme] = renderer
    }
    
    static func named(_ name: String) -> (any MarkdownLinkRenderer)? {
        if let renderer = MarkdownLinkRenderers.shared.renderers[name] {
            return renderer
        }
        
        let lowercaseName = name.lowercased()
        return MarkdownLinkRenderers.shared
            .renderers
            .first(where: { $0.key.lowercased() == lowercaseName })?
            .value
    }
}
