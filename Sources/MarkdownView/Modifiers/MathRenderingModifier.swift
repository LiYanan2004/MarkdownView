//
//  MathRenderingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI

extension View {
    public func markdownMathRenderingEnabled(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.rendersInlineMathIfPossible = enabled
        }
    }
}
