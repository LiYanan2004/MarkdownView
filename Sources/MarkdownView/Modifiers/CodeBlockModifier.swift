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
}
