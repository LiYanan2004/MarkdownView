import SwiftUI
import Markdown

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Renderer {
    mutating func visitTable(_ table: Markdown.Table) -> Result {
        let table = AnyView(
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow { visitTableHead(table.head).view }
                visitTableBody(table.body).view
            }
                .padding(16)
                .border(.tertiary)
        )
        return Result(table)
    }
    
    mutating func visitTableHead(_ head: Markdown.Table.Head) -> Result {
        var contents = [AnyView]()
        for tableCell in head.cells {
            contents.append(visitTableCell(tableCell).view)
        }
        
        let head = AnyView(ForEach(contents.indices, id: \.self) {
            contents[$0].font(.headline)
        })
        return Result(head)
    }
    
    mutating func visitTableBody(_ body: Markdown.Table.Body) -> Result {
        var contents = [AnyView]()
        for tableRow in body.rows {
            contents.append(visitTableRow(tableRow).view)
        }
        
        let body = AnyView(ForEach(contents.indices, id: \.self) {
            Divider()
            contents[$0]
        })
        return Result(body)
    }
    
    mutating func visitTableRow(_ row: Markdown.Table.Row) -> Result {
        var contents = [AnyView]()
        for tableCell in row.cells {
            let cell = visitTableCell(tableCell).text.gridColumnAlignment(tableCell.alignment)
            contents.append(AnyView(cell.gridCellColumns(Int(tableCell.colspan))))
        }
        
        let row = AnyView(GridRow {
            ForEach(contents.indices, id: \.self) {
                contents[$0]
            }
        })
        return Result(row)
    }
    
    mutating func visitTableCell(_ cell: Markdown.Table.Cell) -> Result {
        var text = [SwiftUI.Text]()
        for child in cell.children {
            text.append(visit(child).text)
        }
        
        return Result(text)
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
                case .none: return .center
                }
            }

            currentElement = currentElement?.parent
        }
        return .center
    }
}
