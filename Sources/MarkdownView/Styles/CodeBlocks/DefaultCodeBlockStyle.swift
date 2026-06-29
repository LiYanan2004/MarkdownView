//
//  DefaultCodeBlockStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/3/25.
//

import SwiftUI

/// Default code block style that applies to a MarkdownView.
public struct DefaultCodeBlockStyle: MarkdownCodeBlockStyle {
    /// Theme configuration in the current context.
    public var highlighterTheme: CodeHighlighterTheme
    
    /// Creates a default code block style.
    ///
    /// - Parameter highlighterTheme: The syntax highlighting theme configuration.
    public init(
        highlighterTheme: CodeHighlighterTheme = CodeHighlighterTheme(
            lightModeThemeName: "xcode",
            darkModeThemeName: "dark"
        )
    ) {
        self.highlighterTheme = highlighterTheme
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        DefaultMarkdownCodeBlock(
            codeBlockConfiguration: configuration,
            theme: highlighterTheme
        )
    }
}

extension MarkdownCodeBlockStyle where Self == DefaultCodeBlockStyle {
    /// Default code block theme with light theme called "xcode" and dark theme called "dark".
    static public var `default`: DefaultCodeBlockStyle { .init() }
    
    /// Default code block theme with customized light & dark themes.
    static public func `default`(
        lightTheme: String = "xcode",
        darkTheme: String = "dark"
    ) -> DefaultCodeBlockStyle {
        .init(
            highlighterTheme: CodeHighlighterTheme(
                lightModeThemeName: lightTheme,
                darkModeThemeName: darkTheme
            )
        )
    }
}
