//
//  ForegroundStyleModifier.swift
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
    nonisolated public func foregroundStyleGroup(
        _ foregroundStyleGroup: some MarkdownForegroundStyleGroup
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.foregroundStyleGroup = AnyMarkdownForegroundStyleGroup(
                foregroundStyleGroup
            )
        }
    }
    
    /// Sets foreground style for the specific component in MarkdownView.
    ///
    /// - Parameters:
    ///   - style: The style to apply to this type of components.
    ///   - component: The type of components to apply the foreground style.
    nonisolated public func foregroundStyle(
        _ style: some ShapeStyle,
        for component: MarkdownStyleTarget
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration.foregroundStyleGroup) { foregroundStyleGroup in
            let erasedShapeStyle = AnyShapeStyle(style)
            switch component {
            case .h1: foregroundStyleGroup._h1 = erasedShapeStyle
            case .h2: foregroundStyleGroup._h2 = erasedShapeStyle
            case .h3: foregroundStyleGroup._h3 = erasedShapeStyle
            case .h4: foregroundStyleGroup._h4 = erasedShapeStyle
            case .h5: foregroundStyleGroup._h5 = erasedShapeStyle
            case .h6: foregroundStyleGroup._h6 = erasedShapeStyle
            case .blockQuote: foregroundStyleGroup._blockQuote = erasedShapeStyle
            case .codeBlock: foregroundStyleGroup._codeBlock = erasedShapeStyle
            case .tableBody: foregroundStyleGroup._tableBody = erasedShapeStyle
            case .tableHeader: foregroundStyleGroup._tableHeader = erasedShapeStyle
            }
        }
    }
}
