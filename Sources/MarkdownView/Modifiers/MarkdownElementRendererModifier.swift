//
//  MarkdownElementRendererModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/1.
//

import SwiftUI

extension SwiftUI.View {
    /// Registers a custom renderer for markdown elements in this view hierarchy.
    ///
    /// Register a renderer with the same block directive name or URL scheme to replace an earlier registration in the same scope.
    ///
    /// - Parameter registration: The renderer registration to apply.
    /// - Returns: A view that uses the specified registration when rendering markdown content.
    nonisolated public func markdownElementRenderer(_ registration: MarkdownElementRendererRegistration) -> some View {
        transformEnvironment(\.markdownElementRenderers) { renderers in
            renderers.register(registration)
        }
    }
}

// MARK: - Deprecated

extension SwiftUI.View {
    /// Registers a custom renderer for block directives with the specified name.
    ///
    /// - Parameter renderer: The renderer to use for matching block directives.
    /// - Parameter name: The block directive name to match.
    /// - Returns: A view that uses the specified renderer for matching block directives.
    @available(*, deprecated, message: "Use markdownElementRenderer(.blockDirective(_:name:)) instead.")
    nonisolated public func blockDirectiveRenderer(
        _ renderer: some MarkdownBlockDirectiveRenderer,
        for name: String
    ) -> some View {
        markdownElementRenderer(.blockDirective(renderer, name: name))
    }
    
    /// Registers a custom renderer for images with the specified URL scheme.
    ///
    /// - Parameter renderer: The renderer to use for matching image URLs.
    /// - Parameter urlScheme: The URL scheme to match.
    /// - Returns: A view that uses the specified renderer for matching image URLs.
    @available(*, deprecated, message: "Use markdownElementRenderer(.image(_:urlScheme:)) instead.")
    nonisolated public func markdownImageRenderer(
        _ renderer: some MarkdownImageRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        markdownElementRenderer(.image(renderer, urlScheme: urlScheme))
    }
    
    /// Registers a custom renderer for links with the specified URL scheme.
    ///
    /// - Parameter renderer: The renderer to use for matching link URLs.
    /// - Parameter urlScheme: The URL scheme to match.
    /// - Returns: A view that uses the specified renderer for matching link URLs.
    @available(*, deprecated, message: "Use markdownElementRenderer(.link(_:urlScheme:)) instead.")
    nonisolated public func markdownLinkRenderer(
        _ renderer: some MarkdownLinkRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        markdownElementRenderer(.link(renderer, urlScheme: urlScheme))
    }
}
