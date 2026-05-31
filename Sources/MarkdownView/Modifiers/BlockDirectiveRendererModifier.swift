//
//  BlockDirectiveRendererModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
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
}
