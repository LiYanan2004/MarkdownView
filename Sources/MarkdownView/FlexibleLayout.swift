import SwiftUI

struct FlexibleLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let totalWidth = proposal.width else { return .zero }

        let proposal = ProposedViewSize(width: totalWidth, height: nil)
        
        var size = CGSize.zero
        var x = CGFloat.zero
        var y = CGFloat.zero
        var rowHeight = CGFloat.zero
        
        subviews.forEach {
            let subviewSize = $0.sizeThatFits(proposal)

            if x + subviewSize.width > totalWidth {
                // This element cannot be accommodated horizontally.
                // Increase the height.
                y += rowHeight
                x = .zero
                rowHeight = subviewSize.height
            }
            rowHeight = max(subviewSize.height, rowHeight)
            x += subviewSize.width
            size.width = min(subviewSize.width + size.width, totalWidth)
            size.height = max(y + subviewSize.height, size.height)
        }
        return size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard let totalWidth = proposal.width else { return }
        
        let proposal = ProposedViewSize(width: totalWidth, height: nil)
        
        var rowHeight = CGFloat.zero
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        
        var viewRects = [ViewRect]()
        subviews.indices.forEach {
            let subviewSize = subviews[$0].sizeThatFits(proposal)
            
            if x + subviewSize.width > bounds.maxX {
                // Place the last row.
                placeView(&viewRects, rowHeight: rowHeight)
                y += rowHeight
                x = bounds.minX
                rowHeight = .zero
            }
            
            let viewRect = ViewRect(element: subviews[$0], topLeadingPoint: CGPoint(x: x, y: y), size: subviewSize)
            viewRects.append(viewRect)
            rowHeight = max(subviewSize.height, rowHeight)
            x += subviewSize.width
        }
        
        // Place the last row.
        placeView(&viewRects, rowHeight: rowHeight)
    }
    
    private func placeView(_ viewRects: inout [ViewRect], rowHeight: CGFloat) {
        for view in viewRects {
            let proposal = ProposedViewSize(view.size)
            let centerPoint = CGPoint(x: view.topLeadingPoint.x, y: view.topLeadingPoint.y + rowHeight / 2)
            view.element.place(at: centerPoint, anchor: .leading, proposal: proposal)
        }
        viewRects.removeAll()
    }
    
    struct ViewRect {
        var element: LayoutSubviews.Element
        var topLeadingPoint: CGPoint
        var size: CGSize
    }
}
