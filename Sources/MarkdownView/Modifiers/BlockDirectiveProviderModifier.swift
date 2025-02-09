//
//  BlockDirectiveProviderModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Adds your custom block directive provider.
    ///
    /// - parameters:
    ///     - provider: The provider you have created to handle block displaying.
    ///     - name: The name of the  block directive.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this provider multiple times if you have multiple providers.
    public func blockDirectiveProvider(
        _ provider: some BlockDirectiveDisplayable, for name: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.blockDirectiveRenderer.addProvider(provider, for: name)
        }
    }
}
