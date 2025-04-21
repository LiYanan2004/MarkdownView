//
//  MarkdownTableCellOverlayModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

extension View {
    /// Sets custom overlay content for markdown table cells within the view hierarchy.
    ///
    /// Use this modifier to add overlay decorations (e.g cell borders, etc.) to every cell within a table.
    ///
    /// In this example, we add borders to each cell and set cell padding:
    ///
    /// ```swift
    /// struct GridTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.table.header
    ///                 .markdownTableCellOverlay {
    ///                     Rectangle()
    ///                         .stroke()
    ///                         .ignoresSafeArea()
    ///                 }
    ///             ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { (_, row) in
    ///                 row
    ///                     .markdownTableCellOverlay {
    ///                         Rectangle()
    ///                             .stroke()
    ///                             .ignoresSafeArea()
    ///                     }
    ///             }
    ///         }
    ///         .markdownTableCellPadding(8)
    ///     }
    /// }
    /// ```
    nonisolated public func markdownTableCellOverlay<Content: View>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View {
        environment(\.markdownTableCellOverlayContent, AnyView(content()))
    }
}
