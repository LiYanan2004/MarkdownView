//
//  ImageProviderModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Add your own providers to render images.
    ///
    /// - parameters
    ///     - provider: The provider you created to handle image loading and displaying.
    ///     - urlScheme: A scheme for the renderer to determine when to use the provider.
    /// - Returns: View that able to render images with specific schemes.
    ///
    /// You can set the provider multiple times if you want to add multiple schemes.
    public func imageProvider(
        _ provider: some ImageDisplayable, forURLScheme urlScheme: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.imageRenderer.addProvider(provider, forURLScheme: urlScheme)
        }
    }
}
