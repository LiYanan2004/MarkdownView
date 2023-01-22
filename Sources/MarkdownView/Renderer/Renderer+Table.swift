import SwiftUI
import Markdown

extension Renderer {
    mutating func visitTable(_ table: Markdown.Table) -> Result {
        return Result {
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow { visitTableHead(table.head).content }
                    visitTableBody(table.body).content
                }
                .padding(16)
                .border(.tertiary)
            }
        }
    }
    
    mutating func visitTableHead(_ head: Markdown.Table.Head) -> Result {
        var contents = [AnyView]()
        for tableCell in head.cells {
            contents.append(visitTableCell(tableCell).view)
        }
        
        return Result {
            ForEach(contents.indices, id: \.self) {
                contents[$0].font(.headline)
            }
        }
    }
    
    mutating func visitTableBody(_ body: Markdown.Table.Body) -> Result {
        var contents = [AnyView]()
        for tableRow in body.rows {
            contents.append(visitTableRow(tableRow).view)
        }
        
        return Result {
            ForEach(contents.indices, id: \.self) {
                Divider()
                contents[$0]
            }
        }
    }
    
    mutating func visitTableRow(_ row: Markdown.Table.Row) -> Result {
        Result {
            let cells = row.children.map { $0 as! Markdown.Table.Cell }
            let contents: [Result] = cells.map { visitTableCell($0) }
            if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                GridRow {
                    ForEach(contents.indices, id: \.self) { index in
                        let tableCell = cells[index]
                        contents[index].content
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .gridColumnAlignment(tableCell.alignment)
                            .gridCellColumns(Int(tableCell.colspan))
                    }
                }
            }
        }
    }
    
    mutating func visitTableCell(_ cell: Markdown.Table.Cell) -> Result {
        print("\n", cell.debugDescription())
        return Result(cell.children.map { visit($0) })
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
