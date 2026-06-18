import SwiftUI

struct GridContainer {
    var rows: [GridRowContainer]
    var cells: [GridCellContainer] {
        rows.lazy.flatMap { $0.cells }
    }
    
    init(rows: [GridRowContainer]) {
        self.rows = rows
    }
}

extension GridContainer {
     init(@GridBuilder _ grid: () -> GridContainer) {
        self = grid()
    }
}

@resultBuilder struct GridBuilder {
    static func buildBlock(_ grids: GridContainer...) -> GridContainer {
        var container = GridContainer(rows: [])
        for grid in grids {
            container.rows.append(contentsOf: grid.rows)
        }
        return container
    }

    static func buildExpression(_ row: GridRowContainer) -> GridContainer {
        GridContainer(rows: [row])
    }

    static func buildArray(_ grids: [GridContainer]) -> GridContainer {
        GridContainer(rows: grids.flatMap { $0.rows })
    }
}
