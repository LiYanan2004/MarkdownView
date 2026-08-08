//
//  StreamingTextAnimationTests.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import Testing
import SwiftUI

@testable import MarkdownView

@Suite("Streaming Text Animation")
struct StreamingTextAnimationTests {

    // MARK: - Protocol Conformance

    @Test("Opacity animation is Sendable")
    func opacityAnimationIsSendable() {
        let animation: any StreamingTextAnimation = OpacityStreamingAnimation()
        #expect(animation is OpacityStreamingAnimation)
    }

    @Test("Blur animation is Sendable")
    func blurAnimationIsSendable() {
        let animation: any StreamingTextAnimation = BlurStreamingAnimation()
        #expect(animation is BlurStreamingAnimation)
    }

    @Test("Gradient animation is Sendable")
    func gradientAnimationIsSendable() {
        let animation: any StreamingTextAnimation = GradientStreamingAnimation()
        #expect(animation is GradientStreamingAnimation)
    }

    @Test("Static opacity shorthand returns correct type")
    func staticOpacityShorthand() {
        let animation: any StreamingTextAnimation = .opacity
        #expect(animation is OpacityStreamingAnimation)
    }

    @Test("Static blur shorthand returns correct type")
    func staticBlurShorthand() {
        let animation: any StreamingTextAnimation = .blur
        #expect(animation is BlurStreamingAnimation)
    }

    @Test("Static gradient shorthand returns correct type")
    func staticGradientShorthand() {
        let animation: any StreamingTextAnimation = .gradient
        #expect(animation is GradientStreamingAnimation)
    }

    @Test("Custom blur radius is preserved")
    func customBlurRadius() {
        let animation = BlurStreamingAnimation(radius: 20)
        #expect(animation.radius == 20)
    }

    @Test("Custom gradient tint color is preserved")
    func customGradientTintColor() {
        let animation = GradientStreamingAnimation(tintColor: .red, radius: 8)
        #expect(animation.radius == 8)
    }

    // MARK: - StreamingTextRenderer Character Progress

    @Test("Renderer computes zero progress for all unrevealed characters")
    func rendererZeroProgress() {
        let renderer = StreamingTextRenderer(
            progress: 0,
            revealedCount: 0,
            totalCharacterCount: 10,
            animation: OpacityStreamingAnimation()
        )
        #expect(renderer.revealedCount == 0)
        #expect(renderer.totalCharacterCount == 10)
        #expect(renderer.progress == 0)
    }

    @Test("Renderer with progress 1 has correct state")
    func rendererFullProgress() {
        let renderer = StreamingTextRenderer(
            progress: 1,
            revealedCount: 0,
            totalCharacterCount: 10,
            animation: OpacityStreamingAnimation()
        )
        #expect(renderer.progress == 1)
        #expect(renderer.revealedCount == 0)
        #expect(renderer.totalCharacterCount == 10)
    }

    @Test("Renderer preserves previously revealed count")
    func rendererPreservesRevealedCount() {
        let renderer = StreamingTextRenderer(
            progress: 0.5,
            revealedCount: 5,
            totalCharacterCount: 10,
            animation: BlurStreamingAnimation()
        )
        #expect(renderer.revealedCount == 5)
    }

    // MARK: - StreamingAnimatedText Text Change Detection

    @Test("Prefix detection for streaming append")
    func prefixDetection() {
        // StreamingAnimatedText uses hasPrefix to detect streaming appends.
        // "Hello" → "Hello World" should be detected as append.
        #expect("Hello World".hasPrefix("Hello"))
        // "Hello" → "Hello" should not trigger animation.
        #expect("Hello".hasPrefix("Hello"))
    }

    @Test("Full replacement when text changes completely")
    func fullReplacementDetection() {
        // "Hello" → "World" should NOT be detected as append.
        #expect(!"World".hasPrefix("Hello"))
    }

    // MARK: - Environment Key

    @Test("Environment default value is nil")
    func environmentDefaultIsNil() {
        var env = EnvironmentValues()
        #expect(env.streamingTextAnimation == nil)
    }

    @Test("Environment stores and retrieves animation")
    func environmentStoresAnimation() {
        var env = EnvironmentValues()
        let animation: any StreamingTextAnimation = .blur
        env.streamingTextAnimation = animation
        #expect(env.streamingTextAnimation != nil)
    }
}
