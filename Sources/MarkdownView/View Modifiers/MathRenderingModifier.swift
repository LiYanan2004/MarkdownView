//
//  MathRenderingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI

extension View {
    /// Opts the surrounding Markdown views into parsing and rendering math expressions.
    ///
    /// Math support is disabled by default so plain Markdown renders quickly.
    /// Calling this modifier rewrites display math blocks (`$$ ... $$`) into a
    /// block-directive placeholder that is then rendered through LaTeXSwiftUI on
    /// iOS and macOS. On other platforms the directive safely degrades to an
    /// empty view.
    ///
    /// ```swift
    /// MarkdownView(markdown)
    ///     .markdownMathRenderingEnabled()
    /// ```
    ///
    /// - Parameter enabled: Set to `false` to temporarily suppress math parsing
    ///   for a subtree. The default is `true`, which turns math rendering on for
    ///   the given view hierarchy.
    nonisolated public func markdownMathRenderingEnabled(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.math.isEnabled = enabled
            if enabled {
                configuration.allowedBlockDirectiveRenderers.insert("math")
                BlockDirectiveRenderers.shared.addRenderer(
                    MathBlockDirectiveRenderer(),
                    for: "math"
                )
            }
        }
    }
}
