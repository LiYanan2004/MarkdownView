//
//  StreamingTextAnimation.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

/// A type that defines how text characters are progressively revealed during streaming output.
///
/// Implement this protocol to create custom streaming text animations.
/// Each character receives a progress value from `0` (not yet revealed) to `1` (fully settled),
/// and the animation mutates the ``GraphicsContext`` to apply visual effects.
///
/// ```swift
/// struct MyAnimation: StreamingTextAnimation {
///     func apply(to context: inout GraphicsContext, characterProgress: Double) {
///         context.opacity = characterProgress
///     }
/// }
/// ```
public protocol StreamingTextAnimation: Sendable {
    /// Apply the animation effect for a character at the given reveal progress.
    ///
    /// - Parameters:
    ///   - context: The graphics context to mutate. The context already contains the character's
    ///     text slice, ready to be drawn after mutations are applied.
    ///   - characterProgress: The reveal progress of this character, ranging from `0` (not yet
    ///     revealed) to `1` (fully settled).
    func apply(to context: inout GraphicsContext, characterProgress: Double)
}
