//
//  MarkdownImageRendererModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Use custom renderer to render images.
    ///
    /// - parameter renderer: The render you created to handle image loading and rendering.
    /// - parameter urlScheme: A scheme for deciding which renderer to use.
    nonisolated public func markdownImageRenderer(
        _ renderer: some MarkdownImageRenderer,
        forURLScheme urlScheme: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            MarkdownImageRenders.shared.addRenderer(renderer, forURLScheme: urlScheme)
        }
    }
}
