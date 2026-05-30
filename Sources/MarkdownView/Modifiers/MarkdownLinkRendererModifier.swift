import SwiftUI

extension View {
    nonisolated public func markdownLinkRenderer(
        _ renderer: some MarkdownLinkRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            MarkdownLinkRenderers.shared.addRenderer(renderer, forURLScheme: urlScheme)
            configuration.allowedLinkRenderers.insert(urlScheme)
        }
    }
}
