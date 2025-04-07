import SwiftUI
import Markdown

struct MarkdownTable: View {
    var table: Markdown.Table
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                gridTable
            } else {
                adaptiveGridTable
            }
        }
        .scenePadding()
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 2)
        }
    }
    
    private var adaptiveGridTable: some View {
        AdaptiveGrid(showDivider: true) {
            GridRowContainer {
                for cell in table.head.children {
                    GridCellContainer(alignment: (cell as! Markdown.Table.Cell).alignment) {
                        MarkdownViewRenderer(configuration: configuration)
                            .render(cell)
                            .font(configuration.fontGroup.tableHeader)
                            .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
                    }
                }
            }
            for row in table.body.children {
                GridRowContainer {
                    for cell in row.children {
                        GridCellContainer(alignment: (cell as! Markdown.Table.Cell).alignment) {
                            MarkdownViewRenderer(configuration: configuration)
                                .render(cell)
                                .font(configuration.fontGroup.tableBody)
                                .foregroundStyle(configuration.foregroundStyleGroup.tableBody)
                        }
                    }
                }
            }
        }
    }
    
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    private var gridTable: some View {
        Grid(horizontalSpacing: 8, verticalSpacing: 8) {
            GridRow {
                MarkdownViewRenderer(configuration: configuration)
                    .render(table.head)
            }
            MarkdownViewRenderer(configuration: configuration)
                .render(table.body)
        }
    }
}

struct MarkdownTableHead: View {
    var head: Markdown.Table.Head
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        ForEach(Array(head.children.enumerated()), id: \.offset) { (_, child) in
            MarkdownViewRenderer(configuration: configuration)
                .render(child)
                .font(configuration.fontGroup.tableHeader)
                .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
        }
    }
}


struct MarkdownTableBody: View {
    var tableBody: Markdown.Table.Body
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        ForEach(Array(tableBody.children.enumerated()), id: \.offset) { (_, child) in
            Divider()
            MarkdownViewRenderer(configuration: configuration)
                .render(child)
                .font(configuration.fontGroup.tableBody)
                .foregroundStyle(configuration.foregroundStyleGroup.tableHeader)
        }
    }
}

struct MarkdownTableRow: View {
    var row: Markdown.Table.Row
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            GridRow {
                ForEach(Array(row.children.enumerated()), id: \.offset) { (_, cell) in
                    MarkdownViewRenderer(configuration: configuration)
                        .render(cell as! Markdown.Table.Cell)
                }
            }
        }
    }
}
