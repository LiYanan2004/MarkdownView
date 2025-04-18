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
    /// > Important:
    /// >
    /// > You should set `horizontalSpacing` and `verticalSpacing` to `0` and add spacing between cells manually.
    /// >
    /// > Avoid using `.padding(_:)` to adjust spacing, use `.safeAreaPadding(_:)` instead.
    ///
    /// Here is an example:
    ///
    /// ```swift
    /// struct HighlightedTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.header
    ///                 .safeAreaPadding(8)
    ///                 .markdownTableCellBackgroundStyle(.background)
    ///             ForEach(Array(configuration.rows.enumerated()), id: \.offset) { (index, row) in
    ///                 row
    ///                     .safeAreaPadding(8)
    ///                     .markdownTableCellBackgroundStyle(.red.opacity(0.3), in: .rect(cornerRadius: 5))
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
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
    /// > Important:
    /// >
    /// > You should set `horizontalSpacing` and `verticalSpacing` to `0` and add spacing between cells manually.
    /// >
    /// > Avoid using `.padding(_:)` to adjust spacing, use `.safeAreaPadding(_:)` instead.
    ///
    /// Here is an example:
    ///
    /// ```swift
    /// struct HighlightedTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.header
    ///                 .safeAreaPadding(8)
    ///                 .markdownTableCellBackgroundStyle(.background)
    ///             ForEach(Array(configuration.rows.enumerated()), id: \.offset) { (index, row) in
    ///                 row
    ///                     .safeAreaPadding(8)
    ///                     .markdownTableCellBackgroundStyle(.quatinary)
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    nonisolated public func markdownTableCellBackgroundStyle(
        _ background: some ShapeStyle
    ) -> some View {
        environment(\.markdownTableCellBackgroundStyle, AnyShapeStyle(background))
    }
}
