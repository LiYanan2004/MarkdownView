//
//  MarkdownTableStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI
import Markdown

/// A type that applies a custom appearance to all tables created by MarkdownView within the view hierarchy.
/// 
/// Build custom table styles from `configuration.table.header` and `configuration.table.rows`. Those views preserve parsed table cell alignment, colspan information, table fonts, and table cell customization modifiers.
///
/// Use `Grid(horizontalSpacing: 0, verticalSpacing: 0)` when you need header and body rows to align as one table. Apply table cell modifiers to the table, header, or row views rather than wrapping each cell manually.
///
/// Keep environment-dependent work in a separate `View`. The style is a factory object, so a nested view is the correct place to read `@Environment` values.
///
/// The following example creates a compact table style with a tinted header, alternating row backgrounds, cell padding, and cell borders.
///
/// ```swift
/// struct CompactMarkdownTableStyle: MarkdownTableStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         CompactMarkdownTable(configuration: configuration)
///     }
/// }
///
/// private struct CompactMarkdownTable: View {
///     let configuration: MarkdownTableStyleConfiguration
///
///     var body: some View {
///         Grid(horizontalSpacing: 0, verticalSpacing: 0) {
///             configuration.table.header
///                 .markdownTableRowBackgroundStyle(.quaternary)
///
///             ForEach(Array(configuration.table.rows.enumerated()), id: \.offset) { index, row in
///                 let backgroundStyle = index.isMultiple(of: 2) ? AnyShapeStyle(Color.clear) : AnyShapeStyle(.quaternary)
///                 row.markdownTableRowBackgroundStyle(backgroundStyle)
///             }
///         }
///         .markdownTableCellPadding(.vertical, 6)
///         .markdownTableCellPadding(.horizontal, 10)
///         .markdownTableCellOverlay {
///             Rectangle().strokeBorder(.quaternary)
///         }
///     }
/// }
///
/// MarkdownView(markdown)
///     .markdownTableStyle(CompactMarkdownTableStyle())
/// ```
@preconcurrency
@MainActor
public protocol MarkdownTableStyle {
    /// A view that represents the markdown table.
    associatedtype Body : SwiftUI.View
    
    /// Creates the view that represents the current markdown table.
    ///
    /// Use `Grid` to construct a table.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    
    /// The properties of a markdown table.
    typealias Configuration = MarkdownTableStyleConfiguration
}

// MARK: - Environment Value

struct MarkdownTableStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownTableStyle = DefaultMarkdownTableStyle()
}

extension EnvironmentValues {
    var markdownTableStyle: any MarkdownTableStyle {
        get { self[MarkdownTableStyleKey.self] }
        set { self[MarkdownTableStyleKey.self] = newValue }
    }
}
