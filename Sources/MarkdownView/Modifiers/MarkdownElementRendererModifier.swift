//
//  MarkdownElementRendererModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/1.
//

import SwiftUI

extension SwiftUI.View {
    nonisolated public func markdownElementRenderer(_ registration: MarkdownElementRendererRegistration) -> some View {
        transformEnvironment(\.markdownElementRenderers) { renderers in
            renderers.register(registration)
        }
    }
}

// MARK: - Deprecated

extension SwiftUI.View {
    /// Adds your custom block directive renderer.
    ///
    /// - parameter renderer: The renderer you have created to handle block directive rendering.
    /// - parameter name: The name of the block directive.
    @available(*, deprecated, message: "Use markdownElementRenderer(.blockDirective(_:name:)) instead.")
    nonisolated public func blockDirectiveRenderer(
        _ renderer: some BlockDirectiveRenderer,
        for name: String
    ) -> some View {
        markdownElementRenderer(.blockDirective(renderer, name: name))
    }
    
    /// Use custom renderer to render images.
    ///
    /// - parameter renderer: The render you created to handle image loading and rendering.
    /// - parameter urlScheme: A scheme for deciding which renderer to use.
    @available(*, deprecated, message: "Use markdownElementRenderer(.image(_:urlScheme:)) instead.")
    nonisolated public func markdownImageRenderer(
        _ renderer: some MarkdownImageRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        markdownElementRenderer(.image(renderer, urlScheme: urlScheme))
    }
    
    @available(*, deprecated, message: "Use markdownElementRenderer(.link(_:urlScheme:)) instead.")
    nonisolated public func markdownLinkRenderer(
        _ renderer: some MarkdownLinkRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        markdownElementRenderer(.link(renderer, urlScheme: urlScheme))
    }
}

