import SwiftUI
import Markdown

struct MarkdownTable: View {
    var table: Markdown.Table
    @Environment(\.markdownTableStyle) private var tableStyle
    @Environment(\.markdownRendererConfiguration) var configuration
    
    var body: some View {
        let configuration = MarkdownTableStyleConfiguration(
            header: MarkdownTableStyleConfiguration.Header(table.head),
            rows: table.body.rows.map(MarkdownTableStyleConfiguration.Row.init),
            fallback: MarkdownTableStyleConfiguration.FallbackTable(table)
        )
        tableStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}

struct MarkdownTableHead: View {
    var head: Markdown.Table.Head
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            GridRow {
                let cells = Array(head.children) as! [Markdown.Table.Cell]
                ForEach(Array(cells.enumerated()), id: \.offset) { (_, cell) in
                    CmarkNodeVisitor(configuration: configuration)
                        .makeBody(for: cell)
                        .font(configuration.fontGroup.tableHeader)
                        .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
                        .multilineTextAlignment(cell.textAlignment)
                }
            }
        }
    }
}

struct MarkdownTableBody: View {
    var tableBody: Markdown.Table.Body
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        ForEach(Array(tableBody.children.enumerated()), id: \.offset) { (_, row) in
            CmarkNodeVisitor(configuration: configuration)
                .makeBody(for: row)
                .font(configuration.fontGroup.tableBody)
                .foregroundStyle(configuration.foregroundStyleGroup.tableBody)
        }
    }
}

struct MarkdownTableRow: View {
    var row: Markdown.Table.Row
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            let cells = Array(row.children) as! [Markdown.Table.Cell]
            GridRow {
                ForEach(Array(cells.enumerated()), id: \.offset) { (_, cell) in
                    CmarkNodeVisitor(configuration: configuration)
                        .makeBody(for: cell)
                        .multilineTextAlignment(cell.textAlignment)
                        .gridColumnAlignment(cell.horizontalAlignment)
                        .gridCellColumns(Int(cell.colspan))
                }
            }
        }
    }
}
