//
//  MarkdownTableStyleConfiguration.Table.Row.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI
import Markdown

extension MarkdownTableStyleConfiguration.Table {
    /// A type-erased header row of a table.
    ///
    /// On platforms that does not supports `Grid`, it would be `EmptyView`.
    public struct Row: View {
        var row: Markdown.Table.Row
        @Environment(\.markdownFontGroup.tableBody) private var font
        
        init(_ row: Markdown.Table.Row) {
            self.row = row
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            MarkdownTableRow(
                rowIndex: row.indexInParent + 1 /* header */,
                cells: Array(row.cells)
            )
            .font(font)
        }
    }
}
