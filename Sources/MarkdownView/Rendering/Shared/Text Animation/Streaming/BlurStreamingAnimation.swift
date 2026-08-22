//
//  BlurStreamingAnimation.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

/// A streaming text animation that unblurs characters as they are revealed.
///
/// Characters start at a configurable maximum blur radius and progressively sharpen
/// to full clarity while fading in.
///
/// Use `.markdownStreamingAnimation(.blur)` for a soft reveal effect.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public struct BlurStreamingAnimation: StreamingTextAnimation {
    /// The maximum blur radius applied to characters before they are revealed.
    public let radius: CGFloat

    /// Creates a blur-based streaming text animation.
    ///
    /// - Parameter radius: The maximum blur radius for unrevealed characters. Default is `12`.
    public init(radius: CGFloat = 12) {
        self.radius = radius
    }

    public func apply(to context: inout GraphicsContext, characterProgress: Double) {
        let progress = min(max(characterProgress, 0), 1)
        context.opacity = progress
        context.addFilter(.blur(radius: radius * (1 - progress)))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public extension StreamingTextAnimation where Self == BlurStreamingAnimation {
    /// A streaming animation that unblurs characters with a default radius of `12`.
    static var blur: Self { .init() }

    /// A streaming animation that unblurs characters with a custom radius.
    static func blur(radius: CGFloat) -> Self { .init(radius: radius) }
}
