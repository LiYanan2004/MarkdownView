//
//  StreamingAnimatedText.swift
//  MarkdownView
//
//  Created by Phineas Guo on 2026/7/15.
//

import SwiftUI

/// A view that progressively reveals text characters using a streaming animation.
///
/// When the text content grows (as in streaming markdown), only the newly appended
/// characters animate in. Previously revealed characters remain visible.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
struct StreamingAnimatedText: View {
    private let plainText: String
    private let textContent: TextContent
    private let animation: any StreamingTextAnimation

    @State private var revealedCount: Int = 0
    @State private var animProgress: Double = 1
    @State private var lastPlainText: String = ""
    @State private var animationTarget: Int = 0

    enum TextContent {
        case plain(String)
        case attributed(AttributedString)

        var string: String {
            switch self {
            case .plain(let s): return s
            case .attributed(let a): return String(a.characters)
            }
        }

        func makeText() -> Text {
            switch self {
            case .plain(let s): return Text(s)
            case .attributed(let a): return Text(a)
            }
        }
    }

    init(_ text: String, animation: any StreamingTextAnimation) {
        self.plainText = text
        self.textContent = .plain(text)
        self.animation = animation
    }

    init(_ attributedString: AttributedString, animation: any StreamingTextAnimation) {
        self.plainText = String(attributedString.characters)
        self.textContent = .attributed(attributedString)
        self.animation = animation
    }

    var body: some View {
        AnimationLeaf(
            progress: animProgress,
            revealedCount: revealedCount,
            plainText: plainText,
            textContent: textContent,
            animation: animation
        )
        .onAppear {
            lastPlainText = plainText
            if revealedCount == 0 && !plainText.isEmpty {
                startAnimation()
            }
        }
        .onChange(of: plainText) { newText in
            handleTextChange(newText)
        }
    }

    private func handleTextChange(_ newText: String) {
        guard newText != lastPlainText else { return }

        let isAppend = newText.hasPrefix(lastPlainText)
        lastPlainText = newText

        if isAppend && animProgress < 1 {
            animationTarget = newText.count
            return
        }

        if !isAppend {
            revealedCount = 0
        }
        startAnimation()
    }

    private func startAnimation() {
        animationTarget = plainText.count
        guard animationTarget > revealedCount else { return }

        animProgress = 0
        withAnimation(.easeOut(duration: 0.3)) {
            animProgress = 1
        } completion: {
            revealedCount = animationTarget
        }
    }
}

// MARK: - Animatable Leaf

/// The leaf view that carries the `Animatable` conformance so SwiftUI drives
/// `animatableData` interpolation directly on each animation frame.
@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
private struct AnimationLeaf: View, @MainActor Animatable {
    var progress: Double
    let revealedCount: Int
    let plainText: String
    let textContent: StreamingAnimatedText.TextContent
    let animation: any StreamingTextAnimation

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        textContent.makeText()
            .textRenderer(StreamingTextRenderer(
                progress: progress,
                revealedCount: revealedCount,
                totalCharacterCount: plainText.count,
                animation: animation
            ))
    }
}
