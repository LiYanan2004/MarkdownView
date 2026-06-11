//
//  BlockQuoteStyleModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/23.
//

import SwiftUI

extension View {
    /// Sets the style of block quotes within a MarkdownView.
    nonisolated public func markdownBlockQuoteStyle(_ style: some MarkdownBlockQuoteStyle) -> some View {
        environment(\.blockQuoteStyle, style)
    }

    /// Sets the style of block quotes within a MarkdownView.
    @inlinable
    @available(*, deprecated, renamed: "markdownBlockQuoteStyle")
    nonisolated public func blockQuoteStyle(_ style: some MarkdownBlockQuoteStyle) -> some View {
        markdownBlockQuoteStyle(style)
    }
}
