import SwiftUI
import Markdown

extension Renderer {
    mutating func visitTable(_ table: Markdown.Table) -> Result {
        Result {
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow { visitTableHead(table.head).content }
                    visitTableBody(table.body).content
                }
                .padding(16)
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.quaternary, lineWidth: 2)
                }
            }
        }
    }
    
    mutating func visitTableHead(_ head: Markdown.Table.Head) -> Result {
        Result {
            let contents = contents(of: head)
            let font = configuration.fontProvider.tableHeader
            ForEach(contents.indices, id: \.self) {
                contents[$0].content.font(font)
            }
        }
    }
    
    mutating func visitTableBody(_ body: Markdown.Table.Body) -> Result {
        Result {
            let contents = contents(of: body)
            let font = configuration.fontProvider.tableBody
            ForEach(contents.indices, id: \.self) {
                Divider()
                contents[$0].content.font(font)
            }
        }
    }
    
    mutating func visitTableRow(_ row: Markdown.Table.Row) -> Result {
        Result {
            let cells = row.children.map { $0 as! Markdown.Table.Cell }
            let contents = cells.map { visitTableCell($0) }
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                GridRow {
                    ForEach(contents.indices, id: \.self) { index in
                        let tableCell = cells[index]
                        contents[index].content
                            .gridColumnAlignment(tableCell.alignment)
                            .gridCellColumns(Int(tableCell.colspan))
                    }
                }
            }
        }
    }
    
    mutating func visitTableCell(_ cell: Markdown.Table.Cell) -> Result {
        Result(contents(of: cell), alignment: cell.alignment)
    }
}

extension BasicInlineContainer {
    var alignment: HorizontalAlignment {
        guard parent is any TableCellContainer else { return .center }
        
        let columnIdx = self.indexInParent
        var currentElement = parent
        while currentElement != nil {
            if currentElement is Markdown.Table {
                let alignment = (currentElement as! Markdown.Table).columnAlignments[columnIdx]
                switch alignment {
                case .center: return .center
                case .left: return .leading
                case .right: return .trailing
                case .none: return .leading
                }
            }

            currentElement = currentElement?.parent
        }
        return .center
    }
}
