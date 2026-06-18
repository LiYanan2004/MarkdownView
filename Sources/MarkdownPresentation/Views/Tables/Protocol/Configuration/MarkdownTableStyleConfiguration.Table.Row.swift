//
//  MarkdownTableStyleConfiguration.Table.Row.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI

extension MarkdownTableStyleConfiguration.Table {
    /// A type-erased header row of a table.
    ///
    /// On platforms that does not supports `Grid`, it would be `EmptyView`.
    public struct Row: View {
        var rowIndex: Int
        var cells: [MarkdownTableStyleConfiguration.Table.Cell]
        @Environment(\.markdownFontGroup.tableBody) private var font
        
        package init(
            rowIndex: Int,
            cells: [MarkdownTableStyleConfiguration.Table.Cell]
        ) {
            self.rowIndex = rowIndex
            self.cells = cells
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            MarkdownTableRow(
                rowIndex: rowIndex,
                cells: cells
            )
            .font(Font(font.asPlatformFont))
        }
    }
}
