import SwiftUI

class MarkdownImageRenders: @unchecked Sendable {
    static let shared: MarkdownImageRenders = .init()
    
    private init() { }
    
    /// All the renderers that have been added.
    private(set) var renderers: [String: any MarkdownImageRenderer] = [
        "http"  : NetworkMarkdownImageRenderer(),
        "https" : NetworkMarkdownImageRenderer(),
    ]
    
    /// Add custom renderer for images rendering.
    /// - Parameters:
    ///   - renderer: An image renderer to make image using a url and an alternative text.
    ///   - urlScheme: The url scheme to use the renderer.
    func addRenderer(
        _ renderer: some MarkdownImageRenderer, forURLScheme urlScheme: String
    ) {
        self.renderers[urlScheme] = renderer
    }
    
    static func named(_ name: String) -> (any MarkdownImageRenderer)? {
        if let renderer = MarkdownImageRenders.shared.renderers[name] {
            return renderer
        }
        
        let lowercaseName = name.lowercased()
        return MarkdownImageRenders.shared
            .renderers
            .first(where: { $0.key.lowercased() == lowercaseName })?
            .value
    }
}
