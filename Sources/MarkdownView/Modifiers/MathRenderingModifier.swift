//
//  MathRenderingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI

extension View {
    nonisolated public func markdownMathRenderingEnabled(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.rendersMathIfPossible = enabled
            BlockDirectiveRenderers.shared.addRenderer(MathDirectiveBlockRenderer(), for: "math")
        }
    }
}
