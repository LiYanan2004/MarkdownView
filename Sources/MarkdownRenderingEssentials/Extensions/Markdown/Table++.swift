import Markdown
import SwiftUI

extension Markdown.Table.Cell {
    public var horizontalAlignment: HorizontalAlignment {
        cellAlignment.horizontalAlignment
    }

    public var textAlignment: TextAlignment {
        cellAlignment.textAlignment
    }
}

private extension Markdown.Table.Cell {
    var cellAlignment: CellAlignment {
        guard parent is any TableCellContainer else { return .leading }

        let columnIndex = indexInParent
        var currentElement = parent

        while currentElement != nil {
            if let table = currentElement as? Markdown.Table {
                let alignment = table.columnAlignments[columnIndex]
                switch alignment {
                case .center:
                    return .center
                case .left:
                    return .leading
                case .right:
                    return .trailing
                case .none:
                    return .leading
                }
            }

            currentElement = currentElement?.parent
        }

        return .leading
    }

    enum CellAlignment {
        case leading
        case center
        case trailing

        var textAlignment: TextAlignment {
            switch self {
            case .leading:
                .leading
            case .center:
                .center
            case .trailing:
                .trailing
            }
        }

        var horizontalAlignment: HorizontalAlignment {
            switch self {
            case .leading:
                .leading
            case .center:
                .center
            case .trailing:
                .trailing
            }
        }
    }
}
