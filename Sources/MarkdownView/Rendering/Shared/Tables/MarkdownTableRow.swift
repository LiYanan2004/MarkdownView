//
//  MarkdownTableHeader.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI
import Markdown

struct MarkdownTableRow: View {
    private var rowIndex: Int
    private var cells: [MarkdownTableStyleConfiguration.Table.Cell]
    @Environment(\.markdownTableCellPadding) private var padding
    
    init(
        rowIndex: Int,
        cells: [MarkdownTableStyleConfiguration.Table.Cell]
    ) {
        self.rowIndex = rowIndex
        self.cells = cells
    }
    
    var body: some View {
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
