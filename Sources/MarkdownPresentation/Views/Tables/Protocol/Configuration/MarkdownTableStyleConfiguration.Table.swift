//
//  MarkdownTableStyleConfiguration.Row.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI

extension MarkdownTableStyleConfiguration {
    /// A type-erased view of a table.
    ///
    /// This view uses `Grid` on supported platforms, or `AdaptiveGrid` otherwise.
    ///
    /// Access `header`, `rows`, and `fallback` properties for further customization.
    @preconcurrency
    @MainActor
    public struct Table {
        package var headerCells: [Cell]
        package var bodyRows: [Row]

        package init(headerCells: [Cell], bodyRows: [Row]) {
            self.headerCells = headerCells
            self.bodyRows = bodyRows
        }

        /// The header row of a table.
        public var header: MarkdownTableStyleConfiguration.Table.Header {
            MarkdownTableStyleConfiguration.Table.Header(cells: headerCells)
        }
        /// The body rows of a table.
        public var rows: [MarkdownTableStyleConfiguration.Table.Row] {
            bodyRows
        }
        public var fallback: Fallback {
            Fallback(headerCells: headerCells, bodyRows: bodyRows)
        }
    }
}

extension MarkdownTableStyleConfiguration.Table {
    package struct Cell {
        package var horizontalAlignment: HorizontalAlignment
        package var textAlignment: TextAlignment
        package var colspan: Int
        package var content: AnyView

        package init(
            horizontalAlignment: HorizontalAlignment,
            textAlignment: TextAlignment,
            colspan: Int,
            content: some View
        ) {
            self.horizontalAlignment = horizontalAlignment
            self.textAlignment = textAlignment
            self.colspan = colspan
            self.content = AnyView(content)
        }
    }
}

extension MarkdownTableStyleConfiguration.Table: View {
    @_documentation(visibility: internal)
    public var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                header
                ForEach(Array(rows.enumerated()), id: \.offset) { (_, row) in
                    row
                }
            }
        } else {
            fallback
        }
    }
}
