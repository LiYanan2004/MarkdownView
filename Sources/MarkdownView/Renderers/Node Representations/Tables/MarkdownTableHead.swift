//
//  MarkdownTableHead.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI
import Markdown

struct MarkdownTableHead: View {
    var head: Markdown.Table.Head
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownTableCellPadding) private var padding
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            GridRow {
                let cells = Array(head.children) as! [Markdown.Table.Cell]
                ForEach(Array(cells.enumerated()), id: \.offset) { (index, cell) in
                    CmarkNodeVisitor(configuration: configuration)
                        .makeBody(for: cell)
                        .font(configuration.fontGroup.tableHeader)
                        .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
                        .multilineTextAlignment(cell.textAlignment)
                        ._markdownCellPadding(padding)
                        .modifier(
                            MarkdownTableCellStyleTransformer(
                                row: 0,
                                column: index
                            )
                        )
                }
            }
        }
    }
}
