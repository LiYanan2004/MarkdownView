//
//  MarkdownTableRowBackgroundStyleModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

extension View {
    /// Sets the background style for markdown table rows within a view hierarchy.
    ///
    /// Use this modifier to layer a type that conforms to `Shape` protocol behind a markdown table row. Specify a `ShapeStyle` to fill the shape.
    ///
    /// Here is an example showing how to implement an alternative background table style:
    ///
    /// ```swift
    /// struct AlternativeBackgroundTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.table.header
    ///                 .markdownTableCellBackgroundStyle(.background)
    ///             ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { (index, row) in
    ///                 row
    ///                     .markdownTableRowBackgroundStyle(index % 2 == 0 ? AnyShapeStyle(.background) : AnyShapeStyle(.background.secondary))
    ///             }
    ///         }
    ///         .markdownTableCellPadding(8)
    ///     }
    /// }
    /// ```
    nonisolated public func markdownTableRowBackgroundStyle(
        _ background: some ShapeStyle,
        in shape: some Shape
    ) -> some View {
        transformEnvironment(\.self) { environmentValues in
            environmentValues.markdownTableRowBackgroundStyle = AnyShapeStyle(background)
            environmentValues.markdownTableRowBackgroundShape = _AnyShape(shape)
        }
    }
    
    /// Sets the background style for markdown table rows within a view hierarchy.
    ///
    /// Use this modifier to place a type that conforms to the `ShapeStyle` protocol — like a `Color`, `Material`, or `HierarchicalShapeStyle` — behind a table cell.
    ///
    /// Here is an example showing how to implement an alternative background table style:
    ///
    /// ```swift
    /// struct AlternativeBackgroundTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.table.header
    ///                 .markdownTableCellBackgroundStyle(.background)
    ///             ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { (index, row) in
    ///                 row
    ///                     .markdownTableRowBackgroundStyle(index % 2 == 0 ? AnyShapeStyle(.background) : AnyShapeStyle(.background.secondary))
    ///             }
    ///         }
    ///         .markdownTableCellPadding(8)
    ///     }
    /// }
    /// ```
    nonisolated public func markdownTableRowBackgroundStyle(
        _ background: some ShapeStyle
    ) -> some View {
        environment(\.markdownTableRowBackgroundStyle, AnyShapeStyle(background))
    }
}
