//
//  GradientStreamingAnimation.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

/// A streaming text animation that reveals characters with a colored glow that fades as they settle.
///
/// New characters appear with a configurable tint glow and progressively sharpen
/// to their natural color.
///
/// Use `.markdownStreamingAnimation(.gradient(.blue))` for a colored reveal effect.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct GradientStreamingAnimation: StreamingTextAnimation {
    /// The glow color applied to characters that have not yet been revealed.
    public let tintColor: Color

    /// The maximum glow radius for unrevealed characters.
    public let radius: CGFloat

    /// Creates a gradient-based streaming text animation with a colored glow.
    ///
    /// - Parameters:
    ///   - tintColor: The glow color applied to unrevealed characters. Default is `.accentColor`.
    ///   - radius: The maximum glow radius for unrevealed characters. Default is `6`.
    public init(tintColor: Color = .accentColor, radius: CGFloat = 6) {
        self.tintColor = tintColor
        self.radius = radius
    }

    public func apply(to context: inout GraphicsContext, characterProgress: Double) {
        let progress = min(max(characterProgress, 0), 1)
        context.opacity = progress
        context.addFilter(.shadow(color: tintColor, radius: radius * (1 - progress)))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension StreamingTextAnimation where Self == GradientStreamingAnimation {
    /// A streaming animation with an accent-colored glow reveal.
    static var gradient: Self { .init() }

    /// A streaming animation with a custom tint color glow reveal.
    static func gradient(_ tintColor: Color) -> Self { .init(tintColor: tintColor) }
}
