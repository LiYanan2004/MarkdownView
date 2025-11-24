//
//  MarkdownTableStyleConfiguration.Row.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/21.
//

import SwiftUI
import Markdown

extension MarkdownTableStyleConfiguration {
    /// A type-erased view of a table.
    ///
    /// This view uses `Grid` on supported platforms, or `AdaptiveGrid` otherwise.
    ///
    /// Access `header`, `rows`, and `fallback` properties for further customization.
    @preconcurrency
    @MainActor
    public struct Table {
        var table: Markdown.Table
        /// The header row of a table.
        public var header: MarkdownTableStyleConfiguration.Table.Header {
            MarkdownTableStyleConfiguration.Table.Header(table.head)
        }
        /// The body rows of a table.
        public var rows: [MarkdownTableStyleConfiguration.Table.Row] {
            table.body.rows.map(MarkdownTableStyleConfiguration.Table.Row.init)
        }
        public var fallback: Fallback {
            Fallback(table)
        }
    }
}

extension MarkdownTableStyleConfiguration.Table: View {
    @_documentation(visibility: internal)
    public var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                header
                ForEach(Array(rows.enumerated()), id: \.offset) { (_, row) in
                    row
                }
            }
        } else {
            fallback
        }
    }
}
