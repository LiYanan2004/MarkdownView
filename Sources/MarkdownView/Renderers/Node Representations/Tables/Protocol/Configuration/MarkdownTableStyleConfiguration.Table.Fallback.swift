//
//  MarkdownTableStyleConfiguration.Table.Fallback.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI
import Markdown

extension MarkdownTableStyleConfiguration.Table {
    /// A type-erased fallback table that uses `AdaptiveGrid` for rendering table on older platforms.
    public struct Fallback: View {
        private var table: Markdown.Table
        @Environment(\.markdownRendererConfiguration) private var configuration
        @Environment(\.markdownTableCellPadding) private var padding
        private var showsRowSeparators: Bool = false
        private var horizontalSpacing: CGFloat = 0
        private var verticalSpacing: CGFloat = 0
        
        init(_ table: Markdown.Table) {
            self.table = table
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            AdaptiveGrid(
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                showDivider: showsRowSeparators
            ) {
                GridRowContainer {
                    let cells = Array(table.head.children) as! [Markdown.Table.Cell]
                    for (column, cell) in cells.enumerated() {
                        GridCellContainer(alignment: cell.horizontalAlignment) {
                            CmarkNodeVisitor(configuration: configuration)
                                .makeBody(for: cell)
                                .font(configuration.fontGroup.tableHeader)
                                .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
                                .multilineTextAlignment(cell.textAlignment)
                                ._markdownCellPadding(padding)
                                .modifier(
                                    MarkdownTableCellStyleTransformer(
                                        row: 0,
                                        column: column
                                    )
                                )
                        }
                    }
                }
                for (rowIndex, row) in table.body.children.enumerated() {
                    GridRowContainer {
                        let cells = Array(row.children) as! [Markdown.Table.Cell]
                        for (column, cell) in cells.enumerated() {
                            GridCellContainer(alignment: cell.horizontalAlignment) {
                                CmarkNodeVisitor(configuration: configuration)
                                    .makeBody(for: cell)
                                    .font(configuration.fontGroup.tableBody)
                                    .foregroundStyle(configuration.foregroundStyleGroup.tableBody)
                                    .multilineTextAlignment(cell.textAlignment)
                                    ._markdownCellPadding(padding)
                                    .modifier(
                                        MarkdownTableCellStyleTransformer(
                                            row: rowIndex + 1 /* header */,
                                            column: column
                                        )
                                    )
                            }
                        }
                    }
                }
            }
        }
        
        /// Sets the visibilities of row separators.
        public func showsRowSeparators(_ show: Bool = true) -> MarkdownTableStyleConfiguration.Table.Fallback {
            var fallback = self
            fallback.showsRowSeparators = show
            return fallback
        }
        
        /// Sets the amount of space for two rows.
        public func verticalSpacing(_ spacing: CGFloat) -> MarkdownTableStyleConfiguration.Table.Fallback {
            var fallback = self
            fallback.verticalSpacing = spacing
            return fallback
        }
        
        /// Sets the amount of space for two columns.
        public func horizontalSpacing(_ spacing: CGFloat) -> MarkdownTableStyleConfiguration.Table.Fallback {
            var fallback = self
            fallback.horizontalSpacing = spacing
            return fallback
        }
    }
}
