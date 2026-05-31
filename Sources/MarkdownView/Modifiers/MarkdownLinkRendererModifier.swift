import SwiftUI

extension View {
    @available(*, deprecated, message: "Use markdownElementRenderer(.link(_:urlScheme:)) instead.")
    nonisolated public func markdownLinkRenderer(
        _ renderer: some MarkdownLinkRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        markdownElementRenderer(.link(renderer, urlScheme: urlScheme))
    }
    
    nonisolated public func markdownElementRenderer(_ registration: MarkdownElementRendererRegistration) -> some View {
        transformEnvironment(\.markdownElementRenderers) { renderers in
            renderers.register(registration)
        }
    }
}
