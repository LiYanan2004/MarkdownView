//
//  HeadingStyleModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets heading styles for all heading levels in `MarkdownView`.
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - Parameter group: The heading style group to apply.
    nonisolated public func markdownHeadingStyleGroup(
        _ group: some HeadingStyleGroup
    ) -> some View {
        environment(\.headingStyleGroup, AnyHeadingStyleGroup(group))
    }
    
    /// Sets heading styles for all heading levels in `MarkdownView`.
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - Parameter group: The heading style group to apply.
    @available(*, deprecated, renamed: "markdownHeadingStyleGroup")
    nonisolated public func headingStyleGroup(
        _ group: some HeadingStyleGroup
    ) -> some View {
        markdownHeadingStyleGroup(group)
    }
    
    /// Sets heading styles for all heading levels in `MarkdownView`.
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - Parameter group: The heading style group to apply.
    @available(*, deprecated, renamed: "markdownHeadingStyleGroup")
    nonisolated public func foregroundStyleGroup(
        _ group: some HeadingStyleGroup
    ) -> some View {
        markdownHeadingStyleGroup(group)
    }
    
    /// Sets the heading style for a specific heading level in `MarkdownView`.
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - Parameters:
    ///   - style: The style to apply to headings at the specified level.
    ///   - headingLevel: The heading level to style.
    nonisolated public func markdownHeadingStyle(
        _ style: some ShapeStyle,
        for headingLevel: HeadingLevel
    ) -> some View {
        transformEnvironment(\.headingStyleGroup) { foregroundStyleGroup in
            let erasedShapeStyle = AnyShapeStyle(style)
            switch headingLevel {
            case .h1: foregroundStyleGroup._h1 = erasedShapeStyle
            case .h2: foregroundStyleGroup._h2 = erasedShapeStyle
            case .h3: foregroundStyleGroup._h3 = erasedShapeStyle
            case .h4: foregroundStyleGroup._h4 = erasedShapeStyle
            case .h5: foregroundStyleGroup._h5 = erasedShapeStyle
            case .h6: foregroundStyleGroup._h6 = erasedShapeStyle
            }
        }
    }
    
    /// Sets the heading style for a specific heading level in `MarkdownView`.
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - Parameters:
    ///   - style: The style to apply to headings at the specified level.
    ///   - headingLevel: The heading level to style.
    @available(*, deprecated, renamed: "markdownHeadingStyle")
    nonisolated public func headingStyle(
        _ style: some ShapeStyle,
        for headingLevel: HeadingLevel
    ) -> some View {
        markdownHeadingStyle(style, for: headingLevel)
    }
    
    /// Sets the heading style for a specific heading level in `MarkdownView`.
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - Parameters:
    ///   - style: The style to apply to headings at the specified level.
    ///   - headingLevel: The heading level to style.
    @available(*, deprecated, renamed: "markdownHeadingStyle")
    nonisolated public func foregroundStyle(
        _ style: some ShapeStyle,
        for headingLevel: HeadingLevel
    ) -> some View {
        markdownHeadingStyle(style, for: headingLevel)
    }
}
