import SwiftUI

protocol GridRowProtocol {
    var cells: [GridCellContainer] { get }
}

struct GridRowContainer: GridRowProtocol {
    var index: Int?
    var cells: [GridCellContainer]
    var count: Int { cells.count }
    
    init(index: Int? = nil, cells: [GridCellContainer]) {
        self.index = index
        self.cells = cells
    }
}

extension GridRowContainer {
    init(index: Int, @GridRowBuilder _ row: () -> GridRowContainer) {
        let row = row()
        self.init(index: index, cells: row.cells)
    }
}

@resultBuilder struct GridRowBuilder {
    static func buildBlock(_ components: GridRowContainer...) -> GridRowContainer {
        var container = GridRowContainer(cells: [])
        for component in components {
            container.cells.append(contentsOf: component.cells)
        }
        return container
    }
    
    static func buildExpression(_ cell: GridCellContainer) -> GridRowContainer {
        GridRowContainer(cells: [cell])
    }
    
    static func buildExpression(_ cells: [GridCellContainer]) -> GridRowContainer {
        GridRowContainer(cells: cells)
    }
    
    static func buildArray(_ components: [GridRowContainer]) -> GridRowContainer {
        GridRowContainer(cells: components.flatMap { $0.cells })
    }
    
    static func buildExpression(_ expression: some View) -> GridRowContainer {
        GridRowContainer(cells: [GridCellContainer(content: expression)])
    }
}
