//
//  MarkdownTableCellStyleTransformer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableCellStyleTransformer: ViewModifier {
    var row: Int
    var column: Int
    
    @Environment(\.markdownTableCellBackgroundStyle) private var cellBackgroundStyle
    @Environment(\.markdownTableCellBackgroundShape) private var cellBackgroundShape
    @Environment(\.markdownTableCellOverlayContent) private var overlayContent
    
    @Environment(\.markdownTableRowBackgroundStyle) private var rowBackgroundStyle
    @Environment(\.markdownTableRowBackgroundShape) private var rowBackgroundShape
    
    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                let rect = proxy.frame(in: .named(MarkdownTable.CoordinateSpaceName))
                Rectangle()
                    .fill(.clear)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
                    .transformPreference(
                        MarkdownTableRowStyleCollectionPreference.self
                    ) { rowStyleCollection in
                        let position = MarkdownTableRowStyle.Position(
                            column: column,
                            row: row
                        )
                        var tableRowStyle = MarkdownTableRowStyle(
                            position: position,
                            minY: rect.minY,
                            maxY: rect.maxY
                        )
                        tableRowStyle.backgroundStyle = rowBackgroundStyle
                        tableRowStyle.backgroundShape = rowBackgroundShape
                        rowStyleCollection[position] = tableRowStyle
                    }
                    .transformPreference(
                        MarkdownTableCellStyleCollectionPreference.self
                    ) { styleCollection in
                        let position = MarkdownTableCellStyle.Position(
                            column: column,
                            row: row
                        )
                        var tableCellStyle = MarkdownTableCellStyle(
                            position: position,
                            rect: rect
                        )
                        tableCellStyle.backgroundStyle = cellBackgroundStyle
                        tableCellStyle.backgroundShape = cellBackgroundShape
                        tableCellStyle.overlayContent = overlayContent
                        styleCollection[tableCellStyle.position] = tableCellStyle
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
    }
}

