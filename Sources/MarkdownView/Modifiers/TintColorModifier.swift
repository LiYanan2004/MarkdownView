//
//  TintColorModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension SwiftUI.View {
    /// Sets the tint color for specific markdown tintable component.
    ///
    /// - Parameters:
    ///   - tint: The tint color to apply.
    ///   - component: The tintable component to apply the tint color.
    nonisolated public func tint(
        _ tint: Color,
        for component: MarkdownTintableComponent
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            switch component {
                case .blockQuote:
                    configuration.tintColors[.blockQuote] = tint
                case .inlineCodeBlock:
                    configuration.tintColors[.inlineCodeBlock] = tint
                case .link:
                    configuration.tintColors[.link] = tint
            }
        }
    }
}
