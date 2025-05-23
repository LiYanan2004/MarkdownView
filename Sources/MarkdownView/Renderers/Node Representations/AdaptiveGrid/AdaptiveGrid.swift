import SwiftUI

/// An adaptive grid that dynamically adjust column width to best fit the content.
struct AdaptiveGrid: View {
    var rows: [GridRowContainer]
    var horizontalSpacing: CGFloat?
    var verticalSpacing: CGFloat?
    var showDivider: Bool
    
    private var columnsCount: Int
    // The width of each cell.
    @State private var cellSizes: [CGFloat]
    // The width of each column
    @State private var colWidths: [CGFloat]
    @State private var height = CGFloat.zero
    // The width of the whole table
    @State private var _width = CGFloat.zero
    
    /// Create an adaptive grid that dynamically adjust column width to best fit the content.
    /// - Parameters:
    ///   - horizontalSpacing: The spacing between two elements in the x axis.
    ///   - verticalSpacing: The spacing between two elements in the y axis.
    ///   - showDivider: Whether to show dividers between rows.
    ///   - content: The content container of the grid.
    init(horizontalSpacing: CGFloat? = nil, verticalSpacing: CGFloat? = nil, showDivider: Bool = false, content: GridContainer) {
        self.rows = content.rows
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.showDivider = showDivider
        
        columnsCount = self.rows.reduce(0) { max($1.count, $0) }
        let sizes = [CGFloat](repeating: .greatestFiniteMagnitude, count: self.rows.count * columnsCount)
        // Save widths of all cells and calculate relative width for each column
        _cellSizes = State(initialValue: sizes)
        _colWidths = State(initialValue: [CGFloat](repeating: .greatestFiniteMagnitude, count: columnsCount))
    }
    
    /// Create an adaptive grid that dynamically adjust column width to best fit the content.
    /// - Parameters:
    ///   - horizontalSpacing: The spacing between two elements in the x axis.
    ///   - verticalSpacing: The spacing between two elements in the y axis.
    ///   - showDivider: Whether to show dividers between rows.
    ///   - content: A closure that creates the grid’s rows.
    init(horizontalSpacing: CGFloat? = nil, verticalSpacing: CGFloat? = nil, showDivider: Bool = false, @GridBuilder content: () -> GridContainer) {
        self.rows = content().rows
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.showDivider = showDivider
        
        columnsCount = self.rows.reduce(0) { max($1.count, $0) }
        let sizes = [CGFloat](repeating: .greatestFiniteMagnitude, count: self.rows.count * columnsCount)
        // Save widths of all cells and calculate relative width for each column
        _cellSizes = State(initialValue: sizes)
        _colWidths = State(initialValue: [CGFloat](repeating: .greatestFiniteMagnitude, count: columnsCount))
    }
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            ForEach(rows.indices, id: \.self) { row in
                AdaptiveGridRow(
                    row: rows[row],
                    columnWidths: colWidths,
                    spacing: horizontalSpacing
                ) { col, width in
                    // Update width of cells
                    let updatingIndex = row * columnsCount + col
                    if updatingIndex < cellSizes.count {
                        cellSizes[updatingIndex] = width
                    }
                    updateLayout()
                }
                if showDivider && rows.count - 1 != row {
                    Divider()
                }
            }
        }
        .background {
            GeometryReader { geometryProxy in
                Color.clear
                    ._task(id: geometryProxy.size) {
                        _width = geometryProxy.size.width
                        updateLayout()
                    }
            }
        }
    }
    
    // Re-calculate column width for table.
    private func updateLayout() {
        var colWidth = [CGFloat](repeating: .zero, count: columnsCount)
        for (index, size) in cellSizes.enumerated() {
            let col = index % columnsCount // [0, (columnsCount - 1)] Represents the column index.
            if colWidth[col] < size {
                colWidth[col] = size
            }
        }
        self.colWidths = colWidth
    }
}

struct AdaptiveGrid_Previews: PreviewProvider {
    static let grid = GridContainer {
        GridRowContainer(index: 0) {
            GridCellContainer {
                Text("Cell")
            }
            GridCellContainer(alignment: .leading) {
                Text("Leading")
            }
        }
        GridRowContainer(index: 1) {
            GridCellContainer {
                Text("Cell")
            }
        }
    }
    
    static var previews: some View {
        AdaptiveGrid(content: grid)
    }
}
