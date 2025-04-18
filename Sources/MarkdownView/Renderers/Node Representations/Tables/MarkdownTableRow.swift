//
//  MarkdownTableRow.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI
import Markdown

struct MarkdownTableRow: View {
    var row: Markdown.Table.Row
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownTableCellBackgroundStyle) private var backgroundStyle
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            let cells = Array(row.children) as! [Markdown.Table.Cell]
            GridRow {
                ForEach(Array(cells.enumerated()), id: \.offset) { (index, cell) in
                    CmarkNodeVisitor(configuration: configuration)
                        .makeBody(for: cell)
                        .multilineTextAlignment(cell.textAlignment)
                        .gridColumnAlignment(cell.horizontalAlignment)
                        .gridCellColumns(Int(cell.colspan))
                        .modifier(
                            MarkdownTableCellStyleTransformer(
                                row: row.indexInParent + /* head */ 1,
                                column: index
                            )
                        )
                }
            }
        }
    }
}
