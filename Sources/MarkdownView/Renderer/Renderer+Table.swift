import SwiftUI
import Markdown

extension Renderer {
    mutating func visitTable(_ table: Markdown.Table) -> AnyView {
        AnyView(
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow { visitTableHead(table.head) }
                visitTableBody(table.body)
            }
                .padding(16)
                .border(.tertiary)
        )
    }
    
    mutating func visitTableHead(_ head: Markdown.Table.Head) -> AnyView {
        var subviews = [AnyView]()
        for tableCell in head.cells {
            subviews.append(visitTableCell(tableCell))
        }
        
        return AnyView(ForEach(subviews.indices, id: \.self) {
            subviews[$0].font(.headline)
        })
    }
    
    mutating func visitTableBody(_ body: Markdown.Table.Body) -> AnyView {
        var subviews = [AnyView]()
        for tableRow in body.rows {
            subviews.append(visitTableRow(tableRow))
        }
        
        return AnyView(ForEach(subviews.indices, id: \.self) {
            Divider()
            subviews[$0]
        })
    }
    
    mutating func visitTableRow(_ row: Markdown.Table.Row) -> AnyView {
        var subviews = [AnyView]()
        for tableCell in row.cells {
            let cell = visitTableCell(tableCell).gridColumnAlignment(tableCell.alignment)
            subviews.append(AnyView(cell))
        }
        
        return AnyView(GridRow {
            ForEach(subviews.indices, id: \.self) {
                subviews[$0]
            }
        })
    }
    
    mutating func visitTableCell(_ cell: Markdown.Table.Cell) -> AnyView {
        var subviews = [AnyView]()
        for child in cell.children {
            subviews.append(visit(child))
        }
        
        return AnyView(FlexibleLayout {
            ForEach(subviews.indices, id: \.self) {
                subviews[$0]
            }
        })
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
