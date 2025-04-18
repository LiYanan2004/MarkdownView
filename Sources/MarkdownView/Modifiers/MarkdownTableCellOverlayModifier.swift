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
    /// > Important:
    /// >
    /// > You should set `horizontalSpacing` and `verticalSpacing` to `0` and add spacing between cells manually.
    /// >
    /// > Avoid using `.padding(_:)` to adjust spacing, use `.safeAreaPadding(_:)` instead.
    ///
    /// Here is an example:
    ///
    /// ```swift
    /// struct MyTableStyle: MarkdownTableStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
    ///             configuration.header
    ///                 .safeAreaPadding(8)
    ///                 .markdownTableCellOverlay {
    ///                     Rectangle()
    ///                         .stroke()
    ///                         .ignoresSafeArea()
    ///                 }
    ///             ForEach(Array(configuration.rows.enumerated()), id: \.offset) { (_, row) in
    ///                 row
    ///                     .safeAreaPadding(8)
    ///                     .markdownTableCellOverlay {
    ///                         Rectangle()
    ///                             .stroke()
    ///                             .ignoresSafeArea()
    ///                     }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    nonisolated public func markdownTableCellOverlay<Content: View>(
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View {
        environment(\.markdownTableCellOverlayContent, AnyView(content()))
    }
}
