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
    private var cells: [Markdown.Table.Cell]
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var customRenderers
    @Environment(\.markdownTableCellPadding) private var padding
    
    init(rowIndex: Int, cells: [Markdown.Table.Cell]) {
        self.rowIndex = rowIndex
        self.cells = cells
    }
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            GridRow {
                ForEach(Array(cells.enumerated()), id: \.offset) { (index, cell) in
                    CmarkNodeVisitor(configuration: configuration, customRenderers: customRenderers)
                        .makeBody(for: cell)
                        .multilineTextAlignment(cell.textAlignment)
                        .gridColumnAlignment(cell.horizontalAlignment)
                        .gridCellColumns(Int(cell.colspan))
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
