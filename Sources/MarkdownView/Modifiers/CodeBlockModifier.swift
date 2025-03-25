//
//  CodeBlockModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the style of code block within a MarkdownView.
    nonisolated public func codeBlockStyle(_ style: some CodeBlockStyle) -> some View {
        environment(\.codeBlockStyle, style)
    }
    
    /// Sets the theme of the code highlighter.
    ///
    /// For more information of available themes, see ``CodeHighlighterTheme``.
    ///
    /// - Parameter theme: The theme for highlighter.
    @available(*, deprecated, message: "Use `.codeBlockStyle(.default(lightTheme:darkTheme:))` instead.")
    nonisolated public func codeHighlighterTheme(_ theme: CodeHighlighterTheme) -> some View {
        codeBlockStyle(
            .default(
                lightTheme: theme.lightModeThemeName,
                darkTheme: theme.darkModeThemeName
            )
        )
    }
}
