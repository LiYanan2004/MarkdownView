//
//  ImageRendererModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Registers a custom renderer for Markdown images that use the given URL scheme.
    ///
    /// Markdown image nodes choose their renderer by looking at the `scheme`
    /// portion of the image URL. By default the built-in HTTP(S) renderer is
    /// available. Call this modifier to support additional schemes (for example
    /// `asset://` to load bundle resources or `ipfs://` to talk to a custom
    /// client).
    ///
    /// The registration performs two actions:
    /// 1. It stores the renderer in a shared registry (the most recently
    ///    registered renderer wins for a given scheme).
    /// 2. It inserts the scheme into the environment’s allow list so the
    ///    renderer is considered during view construction. If an image uses a
    ///    scheme that is not on the allow list, MarkdownView intentionally falls
    ///    back to ``View/markdownBaseURL(_:)`` or to plain text for safety.
    ///
    /// ```swift
    /// struct AssetImageRenderer: MarkdownImageRenderer {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Image(configuration.url.lastPathComponent)
    ///             .resizable()
    ///             .scaledToFit()
    ///     }
    /// }
    ///
    /// MarkdownView(markdown)
    ///     .markdownImageRenderer(AssetImageRenderer(), forURLScheme: "asset")
    /// // Markdown: ![Logo](asset://logo.png)
    /// ```
    ///
    /// - Parameters:
    ///   - renderer: Your renderer type that knows how to load and display the image.
    ///   - urlScheme: The scheme to match (case-insensitive). Use unique schemes
    ///     to avoid clobbering system renderers.
    nonisolated public func markdownImageRenderer(
        _ renderer: some MarkdownImageRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            MarkdownImageRenders.shared.addRenderer(renderer, forURLScheme: urlScheme)
            configuration.allowedImageRenderers.insert(urlScheme)
        }
    }
}
