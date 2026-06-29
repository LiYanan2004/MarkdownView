//
//  MarkdownTableStyleConfiguration.Table.Row.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI

extension MarkdownTableStyleConfiguration.Table {
    /// A type-erased body row of a table.
    public struct Row: View {
        var rowIndex: Int
        var cells: [MarkdownTableStyleConfiguration.Table.Cell]
        @Environment(\.markdownFontGroup.tableBody) private var font
        
        init(
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
            .font(font._swiftUIFont)
        }
    }
}
