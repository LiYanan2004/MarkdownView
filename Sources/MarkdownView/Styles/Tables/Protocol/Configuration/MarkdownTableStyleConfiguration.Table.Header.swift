//
//  MarkdownTableStyleConfiguration.Table.Header.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI

extension MarkdownTableStyleConfiguration.Table {
    /// A type-erased header row of a table.
    public struct Header: View {
        var cells: [MarkdownTableStyleConfiguration.Table.Cell]
        @Environment(\.markdownFontGroup.tableHeader) private var font
        
        init(cells: [MarkdownTableStyleConfiguration.Table.Cell]) {
            self.cells = cells
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            MarkdownTableRow(
                rowIndex: 0,
                cells: cells
            )
            .font(font._swiftUIFont)
        }
    }
}
