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
    
    @Environment(\.markdownTableCellBackgroundStyle) var cellBackgroundStyle
    @Environment(\.markdownTableCellBackgroundShape) var cellBackgroundShape
    @Environment(\.markdownTableCellOverlayContent) var overlayContent
    
    @Environment(\.markdownTableRowBackgroundStyle) var rowBackgroundStyle
    @Environment(\.markdownTableRowBackgroundShape) var rowBackgroundShape
    
    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
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
                            idealHeight: proxy.size.height
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
                            size: proxy.size
                        )
                        tableCellStyle.backgroundStyle = cellBackgroundStyle
                        tableCellStyle.backgroundShape = cellBackgroundShape
                        tableCellStyle.overlayContent = overlayContent
                        styleCollection[tableCellStyle.position] = tableCellStyle
                    }
            }
            .ignoresSafeArea()
        }
    }
}

