//
//  StreamingAnimationModifier.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

public extension View {
    /// Applies a streaming text animation to text content rendered within this view hierarchy.
    ///
    /// When a ``StreamingTextAnimation`` is set, text views inside `MarkdownView` will
    /// progressively reveal new characters as they stream in, using the given animation.
    ///
    /// ```swift
    /// MarkdownView(streamingContent)
    ///     .markdownStreamingAnimation(.blur)
    /// ```
    ///
    /// Built-in animations include:
    /// - ``OpacityStreamingAnimation/opacity`` — fade-in reveal
    /// - ``BlurStreamingAnimation/blur`` — unblur reveal
    /// - ``GradientStreamingAnimation/gradient`` — color-shift reveal
    ///
    /// - Parameter animation: The streaming text animation to apply, or `nil` to disable.
    /// - Returns: A view with the streaming animation environment set.
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    nonisolated func markdownStreamingAnimation(
        _ animation: (any StreamingTextAnimation)?
    ) -> some View {
        environment(\.streamingTextAnimation, animation)
    }
}
