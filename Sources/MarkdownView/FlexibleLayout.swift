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
        subviews.indices.forEach {
            let subviewSize = subviews[$0].sizeThatFits(proposal)
            let subviewProposal = ProposedViewSize(subviewSize)

            if x + subviewSize.width > bounds.maxX {
                y += rowHeight
                x = bounds.minX
                rowHeight = .zero
            }

            subviews[$0].place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: subviewProposal)
            rowHeight = max(subviewSize.height, rowHeight)
            x += subviewSize.width
        }
    }
}
