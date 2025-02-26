//
//  CodeBlockModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the theme of the code highlighter.
    ///
    /// For more information of available themes, see ``CodeHighlighterTheme``.
    ///
    /// - Parameter theme: The theme for highlighter.
    ///
    /// - note: Code highlighting is not available on watchOS.
    nonisolated public func codeHighlighterTheme(_ theme: CodeHighlighterTheme) -> some View {
        environment(\.markdownRendererConfiguration.codeBlockTheme, theme)
    }
}

// MARK: - CodeHighlighterTheme

/// Code highlighting themes configuration for both light and dark mode.
///
/// - note: For more information, Check out [raspu/Highlightr](https://github.com/raspu/Highlightr).
public struct CodeHighlighterTheme: Equatable, Sendable {
    /// The theme name in Light Mode.
    var lightModeThemeName: String
    
    /// The theme name in Dark Mode.
    var darkModeThemeName: String
    
    /// Creates a single theme for both light and dark mode.
    ///
    /// - Parameter themeName: the name of the theme to use in both Light Mode and Dark Mode.
    ///
    /// - warning: You should test the visibility of the code in Light Mode and Dark Mode first.
    public init(themeName: String) {
        lightModeThemeName = themeName
        darkModeThemeName = themeName
    }
    
    /// Creates a combination of two themes that will perfectly adapt both Light Mode and Dark Mode.
    ///
    /// - Parameters:
    ///   - lightModeThemeName: the name of the theme to use in Light Mode.
    ///   - darkModeThemeName: the name of the theme to use in Dark Mode.
    ///
    ///  If you want to use the same theme on both Dark Mode and Light Mode,
    ///  you should use ``init(themeName:)``.
    public init(lightModeThemeName: String, darkModeThemeName: String) {
        self.lightModeThemeName = lightModeThemeName
        self.darkModeThemeName = darkModeThemeName
    }
}
