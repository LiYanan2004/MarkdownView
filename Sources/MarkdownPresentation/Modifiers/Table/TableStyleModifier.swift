//
//  TableStyleModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

extension View {
    /// Sets the style of markdown tables within a MarkdownView.
    nonisolated public func markdownTableStyle(_ style: some MarkdownTableStyle) -> some View {
        environment(\.markdownTableStyle, style)
    }
}
