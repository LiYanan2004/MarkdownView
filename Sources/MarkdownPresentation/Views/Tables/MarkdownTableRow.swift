//
//  MarkdownTableHeader.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI
import Markdown

package struct MarkdownTableRow: View {
    private var rowIndex: Int
    private var cells: [MarkdownTableStyleConfiguration.Table.Cell]
    @Environment(\.markdownTableCellPadding) private var padding
    
    package init(
        rowIndex: Int,
        cells: [MarkdownTableStyleConfiguration.Table.Cell]
    ) {
        self.rowIndex = rowIndex
        self.cells = cells
    }
    
    package var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            GridRow {
                ForEach(Array(cells.enumerated()), id: \.offset) { (index, cell) in
                    cell.content
                        .multilineTextAlignment(cell.textAlignment)
                        .gridColumnAlignment(cell.horizontalAlignment)
                        .gridCellColumns(cell.colspan)
                        ._markdownCellPadding(padding)
                        .modifier(
                            MarkdownTableStylePreferenceSynchronizer(
                                row: rowIndex,
                                column: index
                            )
                        )
                }
            }
        }
    }
}
