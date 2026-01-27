//
//  TintColorModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the tint color for specific MarkdownView component.
    ///
    /// - Parameters:
    ///   - tint: The tint color to apply.
    ///   - component: The tintable component to apply the tint color.
    @ViewBuilder
    nonisolated public func tint(
        _ tint: Color,
        for component: MarkdownTintableComponent
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.preferredTintColors[component] = tint
        }
    }
}

/// Components that can apply a tint color.
@_documentation(visibility: internal)
public enum MarkdownTintableComponent: Hashable, Sendable {
    case blockQuote
    case inlineCodeBlock
    case link
}
