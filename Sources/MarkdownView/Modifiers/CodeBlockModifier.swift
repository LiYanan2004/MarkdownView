//
//  CodeBlockModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the style of code block within a MarkdownView.
    @inlinable
    @available(*, deprecated, renamed: "markdownCodeBlockStyle")
    nonisolated public func codeBlockStyle(_ style: some MarkdownCodeBlockStyle) -> some View {
        markdownCodeBlockStyle(style)
    }
    
    /// Sets the style of code block within a MarkdownView.
    nonisolated public func markdownCodeBlockStyle(_ style: some MarkdownCodeBlockStyle) -> some View {
        environment(\.codeBlockStyle, style)
    }
    
    /// Sets the theme of the code highlighter.
    ///
    /// For more information of available themes, see ``CodeHighlighterTheme``.
    ///
    /// - Parameter theme: The theme for highlighter.
    @available(*, deprecated, message: "Use `.markdownCodeBlockStyle(.default(lightTheme:darkTheme:))` instead.")
    nonisolated public func codeHighlighterTheme(_ theme: CodeHighlighterTheme) -> some View {
        let style = MainActor.assumeIsolated {
            DefaultCodeBlockStyle.default(
                lightTheme: theme.lightModeThemeName,
                darkTheme: theme.darkModeThemeName
            )
        }
        return codeBlockStyle(style)
    }
}
