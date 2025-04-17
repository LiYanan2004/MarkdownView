//
//  MarkdownTableStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI
import Markdown

@preconcurrency
@MainActor
public protocol MarkdownTableStyle {
    /// A view that represents the markdown table.
    associatedtype Body : SwiftUI.View
    
    /// Creates the view that represents the current markdown table.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    
    /// The properties of a markdown table.
    typealias Configuration = MarkdownTableStyleConfiguration
}

/// The properties of a markdown table.
public struct MarkdownTableStyleConfiguration {
    /// The header row of a table.
    public var header: Header
    /// The rows of a table.
    public var rows: [Row]
    /// A fallback view that uses `AdaptiveGrid` for older platform support.
    ///
    /// You can only customize row separators' visibility and spacings.
    ///
    /// - note: Only use this for fallback since it does not support row customization.
    public var fallback: FallbackTable
}

extension MarkdownTableStyleConfiguration {
    /// A type-erased table header row.
    public struct Header: View {
        private var header: MarkdownTableHead
        
        init(_ head: Markdown.Table.Head) {
            self.header = MarkdownTableHead(head: head)
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            header
        }
    }
    
    /// A type-erased table body row.
    public struct Row: View {
        private var row: MarkdownTableRow
        
        init(_ row: Markdown.Table.Row) {
            self.row = MarkdownTableRow(row: row)
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            row
        }
    }
}

@available(*, unavailable)
extension MarkdownTableStyleConfiguration: Sendable {
    
}

extension MarkdownTableStyleConfiguration {
    /// A type-erased fallback table that uses `AdaptiveGrid` for older platforms.
    public struct FallbackTable: View {
        private var table: Markdown.Table
        @Environment(\.markdownRendererConfiguration) private var configuration
        private var showsRowSeparators: Bool = true
        private var horizontalSpacing: CGFloat = 8
        private var verticalSpacing: CGFloat = 8
        
        init(_ table: Markdown.Table) {
            self.table = table
        }
        
        @_documentation(visibility: internal)
        public var body: some View {
            AdaptiveGrid(
                horizontalSpacing: horizontalSpacing,
                verticalSpacing: verticalSpacing,
                showDivider: showsRowSeparators
            ) {
                GridRowContainer {
                    let cells = Array(table.head.children) as! [Markdown.Table.Cell]
                    for cell in cells {
                        GridCellContainer(alignment: cell.horizontalAlignment) {
                            CmarkNodeVisitor(configuration: configuration)
                                .makeBody(for: cell)
                                .font(configuration.fontGroup.tableHeader)
                                .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
                                .multilineTextAlignment(cell.textAlignment)
                        }
                    }
                }
                for row in table.body.children {
                    GridRowContainer {
                        let cells = Array(row.children) as! [Markdown.Table.Cell]
                        for cell in cells {
                            GridCellContainer(alignment: cell.horizontalAlignment) {
                                CmarkNodeVisitor(configuration: configuration)
                                    .makeBody(for: cell)
                                    .font(configuration.fontGroup.tableBody)
                                    .foregroundStyle(configuration.foregroundStyleGroup.tableBody)
                                    .multilineTextAlignment(cell.textAlignment)
                            }
                        }
                    }
                }
            }
        }
        
        /// Sets the visibilities of row separators.
        public func showsRowSeparators(_ show: Bool = true) -> MarkdownTableStyleConfiguration.FallbackTable {
            var fallback = self
            fallback.showsRowSeparators = show
            return fallback
        }
        
        /// Sets the amount of space for two rows.
        public func verticalSpacing(_ spacing: CGFloat) -> MarkdownTableStyleConfiguration.FallbackTable {
            var fallback = self
            fallback.verticalSpacing = spacing
            return fallback
        }
        
        /// Sets the amount of space for two columns.
        public func horizontalSpacing(_ spacing: CGFloat) -> MarkdownTableStyleConfiguration.FallbackTable {
            var fallback = self
            fallback.horizontalSpacing = spacing
            return fallback
        }
    }
}
// MARK: - Environment Value

struct MarkdownTableStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MarkdownTableStyle = DefaultMarkdownTableStyle()
}

extension EnvironmentValues {
    package var markdownTableStyle: any MarkdownTableStyle {
        get { self[MarkdownTableStyleKey.self] }
        set { self[MarkdownTableStyleKey.self] = newValue }
    }
}
