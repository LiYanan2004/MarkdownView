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
    /// Make sure to set `horizontalSpacing` & `verticalSpacing` of a Grid or other layout stacks (e.g. `VStack`) to `0` if you use this modifier.
    ///
    /// Here is an example:
    ///
    /// ```swift
    /// struct MyTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.header
    ///                 .markdownTableRowBackgroundStyle(.background.secondary)
    ///             ForEach(Array(configuration.rows.enumerated()), id: \.offset) { (_, row) in
    ///                 row
    ///             }
    ///         }
    ///         .markdownTableCellPadding(12)
    ///     }
    /// }
    /// ```
    nonisolated public func markdownTableCellPadding(
        _ edges: Edge.Set = .all,
        _ amount: CGFloat
    ) -> some View {
        environment(\.markdownTableCellPadding, MarkdownTableCellPadding(edges, amount: amount))
    }
}
