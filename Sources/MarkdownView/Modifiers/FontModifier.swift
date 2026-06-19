//
//  FontModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {

    /// Apply a font group to MarkdownView.
    ///
    /// Customize fonts for multiple types of text.
    ///
    /// - Parameter fontGroup: A font set to apply to the MarkdownView.
    @inlinable
    @available(*, deprecated, renamed: "markdownFontGroup")
    nonisolated public func fontGroup(_ fontGroup: some MarkdownFontGroup) -> some View {
        markdownFontGroup(fontGroup)
    }

    /// Apply a font group to MarkdownView.
    ///
    /// Customize fonts for multiple types of text.
    ///
    /// - Parameter fontGroup: A font set to apply to the MarkdownView.
    nonisolated public func markdownFontGroup(_ fontGroup: some MarkdownFontGroup) -> some View {
        environment(\.markdownFontGroup, .init(fontGroup))
    }

    /// Sets the font for the specific component for a `MarkdownView` or `MarkdownText`.
    ///
    /// > Note:
    /// > Setting font only takes effect on appleOS 26 or later due to the API coverage.
    /// > If you need to support older OS, supply custom platform font types (`NSFont` / `UIFont` / `CTFont`) via ``font(_:for:)-(CustomCTFontConvertible,_)
    ///
    /// - Parameters:
    ///   - font: The font to apply to these components.
    ///   - type: The type of components to apply the font.
    @_disfavoredOverload
    @inlinable
    nonisolated public func font(
        _ font: Font,
        for type: MarkdownTextType
    ) -> some View {
        self.font(font, for: type)
    }

    /// Sets the font for the specific component for a `MarkdownView` or `MarkdownText`.
    ///
    /// - Parameters:
    ///   - font: The platform font to apply to these components.
    ///   - type: The type of components to apply the font.
    nonisolated public func font(
        _ font: any CustomCTFontConvertible,
        for type: MarkdownTextType
    ) -> some View {
        transformEnvironment(\.markdownFontGroup) { fontGroup in
            switch type {
            case .h1: fontGroup._h1 = font
            case .h2: fontGroup._h2 = font
            case .h3: fontGroup._h3 = font
            case .h4: fontGroup._h4 = font
            case .h5: fontGroup._h5 = font
            case .h6: fontGroup._h6 = font
            case .body: fontGroup._body = font
            case .blockQuote: fontGroup._blockQuote = font
            case .codeBlock: fontGroup._codeBlock = font
            case .tableBody: fontGroup._tableBody = font
            case .tableHeader: fontGroup._tableHeader = font
            case .inlineMath: fontGroup._inlineMath = font
            case .displayMath: fontGroup._displayMath = font
            }
        }
    }
}
