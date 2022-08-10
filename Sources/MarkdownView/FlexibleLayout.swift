import SwiftUI

struct FlexibleLayout: Layout {
    
    func width(proposal: ProposedViewSize, subviews: Subviews) -> CGFloat {
        let totalWidth = subviews.reduce(CGFloat.zero) { result, subview in
            result + subview.sizeThatFits(.infinity).width
        }
        let width = min(proposal.width ?? .infinity, totalWidth)
        
        return width
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = width(proposal: proposal, subviews: subviews)
        var totalHeight: CGFloat = .zero
        
        var currentWidth: CGFloat = .zero
        var maxHeight: CGFloat = .zero
        
        subviews.forEach {
            let subviewSize = $0.sizeThatFits(ProposedViewSize(width: width, height: nil))
            
            totalHeight = max(totalHeight, subviewSize.height)
            
            if currentWidth + subviewSize.width <= width {
                currentWidth += subviewSize.width
                maxHeight = max(subviewSize.height, maxHeight)
            } else {
                totalHeight += maxHeight
                currentWidth = subviewSize.width
                maxHeight = subviewSize.height
            }
        }
        
        return CGSize(width: width, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = width(proposal: proposal, subviews: subviews)
        
        var currentWidth: CGFloat = .zero
        var currentHeight: CGFloat = .zero
        
        subviews.indices.forEach {
            let subviewSize = subviews[$0].sizeThatFits(ProposedViewSize(width: width, height: nil))
            let subviewProposal = ProposedViewSize(subviewSize)
            
            if currentWidth + subviewSize.width <= width {
                currentWidth += subviewSize.width
            } else {
                currentHeight += subviews[max(0, $0 - 1)].sizeThatFits(ProposedViewSize(width: width, height: nil)).height
                currentWidth = subviewSize.width
            }
            
            subviews[$0].place(at: CGPoint(x: bounds.minX + currentWidth, y: bounds.minY + currentHeight), anchor: .topTrailing, proposal: subviewProposal)
        }
    }
}
