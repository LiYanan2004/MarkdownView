//
//  MarkdownTableStyleConfiguration.Table.Header.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI
import Markdown

extension MarkdownTableStyleConfiguration.Table {
    /// A type-erased header row of a table.
    ///
    /// On platforms that does not supports `Grid`, it would be `EmptyView`.
    public struct Header: View {
        var head: Markdown.Table.Head
        @Environment(\.markdownFontGroup.tableHeader) private var font
        
        init(_ head: Markdown.Table.Head) {
            self.head = head
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            MarkdownTableRow(
                rowIndex: 0,
                cells: Array(head.cells)
            )
            .font(font)
        }
    }
}
