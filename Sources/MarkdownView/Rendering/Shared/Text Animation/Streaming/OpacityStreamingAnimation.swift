//
//  OpacityStreamingAnimation.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

/// A streaming text animation that fades characters in from transparent to fully opaque.
///
/// Use `.markdownStreamingAnimation(.opacity)` to apply a simple fade-in effect
/// as markdown content streams in.
public struct OpacityStreamingAnimation: StreamingTextAnimation {
    /// Creates an opacity-based streaming text animation.
    public init() {}

    public func apply(to context: inout GraphicsContext, characterProgress: Double) {
        context.opacity = min(max(characterProgress, 0), 1)
    }
}

public extension StreamingTextAnimation where Self == OpacityStreamingAnimation {
    /// A streaming animation that fades characters from transparent to opaque.
    static var opacity: Self { .init() }
}
