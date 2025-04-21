//
//  MarkdownTableCellPaddingModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

extension View {
    /// Sets paddings for individual markdown table cell within the view hierarchy.
    ///
    /// > tip:
    /// > Make sure to set `horizontalSpacing` & `verticalSpacing` of a `Grid` or other layout stacks (e.g. `VStack`) to `0` to avoid extra spacings.
    ///
    /// In this example, we add background for header row and set cell padding.
    ///
    ///
    /// ```swift
    /// struct MyTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.table.header
    ///                 .markdownTableRowBackgroundStyle(.background.secondary)
    ///             ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { (_, row) in
    ///                 row
    ///             }
    ///         }
    ///         .markdownTableCellPadding(12)
    ///     }
    /// }
    /// ```
    ///
    /// You can use `.padding(_:)` for `header` and `row` since this will apply to all cells within the scope, but it's still recomended to use ``SwiftUICore/View/markdownTableCellPadding(_:_:)`` for this purpose.
    nonisolated public func markdownTableCellPadding(
        _ edges: Edge.Set,
        _ amount: CGFloat
    ) -> some View {
        environment(\.markdownTableCellPadding, MarkdownTableCellPadding(edges, amount: amount))
    }
    
    /// Sets paddings for individual markdown table cell within the view hierarchy.
    ///
    /// > tip:
    /// > Make sure to set `horizontalSpacing` & `verticalSpacing` of a `Grid` or other layout stacks (e.g. `VStack`) to `0` to avoid extra spacings.
    ///
    /// In this example, we add background for header row and set cell padding.
    ///
    ///
    /// ```swift
    /// struct MyTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.table.header
    ///                 .markdownTableRowBackgroundStyle(.background.secondary)
    ///             ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { (_, row) in
    ///                 row
    ///             }
    ///         }
    ///         .markdownTableCellPadding(12)
    ///     }
    /// }
    /// ```
    ///
    /// You can use `.padding(_:)` for `header` and `row` since this will apply to all cells within the scope, but it's still recomended to use ``SwiftUICore/View/markdownTableCellPadding(_:_:)`` for this purpose.
    nonisolated public func markdownTableCellPadding(
        _ amount: CGFloat
    ) -> some View {
        environment(\.markdownTableCellPadding, MarkdownTableCellPadding(.all, amount: amount))
    }
}
