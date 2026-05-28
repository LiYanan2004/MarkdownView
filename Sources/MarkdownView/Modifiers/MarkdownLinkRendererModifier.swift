//
//  MarkdownLinkRendererModifier.swift
//  MarkdownView
//
//  Orbit fork addition. Mirrors `MarkdownImageRendererModifier` so consumers
//  can register a custom view for inline links.
//

import SwiftUI

extension View {
    /// Use custom renderer to render inline links.
    ///
    /// - parameter renderer: The renderer you created to handle link rendering.
    /// - parameter urlScheme: A scheme for deciding which renderer to use.
    ///   Pass `"*"` to register a wildcard renderer that handles every URL
    ///   scheme.
    nonisolated public func markdownLinkRenderer(
        _ renderer: some MarkdownLinkRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.linkRenderers[urlScheme] = AnyMarkdownLinkRenderer(renderer)
        }
    }
}
