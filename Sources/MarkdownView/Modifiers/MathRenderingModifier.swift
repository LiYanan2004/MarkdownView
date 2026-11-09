//
//  MathRenderingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/24.
//

import SwiftUI

extension View {
    /// On macOS and iOS, parse and render math expression.
    ///
    /// - parameter enabled: A Boolean value that indicates whether to parse & render math expressions. The default value is true.
    nonisolated public func markdownMathRenderingEnabled(_ enabled: Bool = true) -> some View {
        modifier(MarkdownMathRenderingModifier(isEnabled: enabled))
    }
}

extension View {
    /// Renders math written for KaTeX: its symbols, commands defined in terms of other commands, and Unicode characters typed into math.
    ///
    /// The first time it renders a formula, it registers KaTeX's symbols in SwiftMath's global symbol table (`MTMathAtomFactory`). SwiftMath's own symbols are kept.
    ///
    /// - parameter enabled: A Boolean value that indicates whether to render math written for KaTeX. The default value is true.
    nonisolated public func markdownMathKaTeXCompatibility(_ enabled: Bool = true) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.mathKaTeXCompatibility = enabled
        }
    }
}

// MARK: - Auxiliary

fileprivate struct MarkdownMathRenderingModifier: ViewModifier {
    let isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .transformEnvironment(\.markdownMathContext) { mathContext in
                mathContext = isEnabled ? (mathContext ?? MarkdownMathContext()) : nil
            }
    }
}
