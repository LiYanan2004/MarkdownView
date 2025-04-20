//
//  MarkdownTableCellBackgroundStyleModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

extension View {
    /// Sets the background style for markdown table cells within a view hierarchy.
    ///
    /// Use this modifier to layer a type that conforms to `Shape` protocol behind a markdown table cell. Specify a `ShapeStyle` to fill the shape.
    ///
    /// - SeeAlso: To set background style for an entire row, use ``SwiftUICore/View/markdownTableRowBackgroundStyle(_:in:)``.
    nonisolated public func markdownTableCellBackgroundStyle(
        _ background: some ShapeStyle,
        in shape: some Shape
    ) -> some View {
        transformEnvironment(\.self) { environmentValues in
            environmentValues.markdownTableCellBackgroundStyle = AnyShapeStyle(background)
            environmentValues.markdownTableCellBackgroundShape = shape
        }
    }
    
    /// Sets the background style for markdown table cells within a view hierarchy.
    ///
    /// Use this modifier to place a type that conforms to the `ShapeStyle` protocol — like a `Color`, `Material`, or `HierarchicalShapeStyle` — behind a table cell.
    ///
    /// - SeeAlso: To set background style for an entire row, use ``SwiftUICore/View/markdownTableRowBackgroundStyle(_:)``.
    nonisolated public func markdownTableCellBackgroundStyle(
        _ background: some ShapeStyle
    ) -> some View {
        environment(\.markdownTableCellBackgroundStyle, AnyShapeStyle(background))
    }
}
