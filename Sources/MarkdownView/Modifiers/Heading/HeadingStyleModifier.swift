//
//  HeadingStyleModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Apply a foreground style group to MarkdownView.
    ///
    /// This is useful when you want to completely customize foreground styles.
    ///
    /// - Parameter foregroundStyleGroup: A style set to apply to the MarkdownView.
    nonisolated public func headingStyleGroup(
        _ group: some HeadingStyleGroup
    ) -> some View {
        environment(\.headingStyleGroup, AnyHeadingStyleGroup(group))
    }
    
    /// Apply a foreground style group to MarkdownView.
    ///
    /// This is useful when you want to completely customize foreground styles.
    ///
    /// - Parameter group: A style set to apply to the MarkdownView.
    @available(*, deprecated, renamed: "headingStyleGroup")
    nonisolated public func foregroundStyleGroup(
        _ group: some HeadingStyleGroup
    ) -> some View {
        headingStyleGroup(group)
    }
    
    /// Sets foreground style for the specific component in MarkdownView.
    ///
    /// - Parameters:
    ///   - style: The style to apply to this type of components.
    ///   - headingLevel: The type of components to apply the foreground style.
    nonisolated public func headingStyle(
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
    
    /// Sets foreground style for the specific component in MarkdownView.
    ///
    /// - Parameters:
    ///   - style: The style to apply to this type of components.
    ///   - headingLevel: The type of components to apply the foreground style.
    @available(*, deprecated, renamed: "headingStyle")
    nonisolated public func foregroundStyle(
        _ style: some ShapeStyle,
        for headingLevel: HeadingLevel
    ) -> some View {
        headingStyle(style, for: headingLevel)
    }
}
