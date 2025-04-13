//
//  MathRenderingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI

extension View {
    /// On macOS and iOS, parse and render math expression.
    ///
    /// - parameter enabled: A Boolean value that indicates whether to parse & render math expressions. The default value is true.
    nonisolated public func markdownMathRenderingEnabled(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.rendersMathIfPossible = enabled
            BlockDirectiveRenderers.shared.addRenderer(MathDirectiveBlockRenderer(), for: "math")
        }
    }
}
