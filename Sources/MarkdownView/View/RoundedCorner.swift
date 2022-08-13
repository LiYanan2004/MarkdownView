//
//  ViewModifiers.swift
//  
//
//  Created by LiYanan2004 on 2022/8/13.
//

import SwiftUI

struct WithRoundedCorner: ViewModifier {
    var cornerRadius: CGFloat
    var side: Side
    
    init(cornerRadius: CGFloat, at side: Side) {
        self.cornerRadius = cornerRadius
        self.side = side
    }
    
    func body(content: Content) -> some View {
        content.mask {
            GeometryReader { proxy in
                switch side {
                case .leading:
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .overlay(alignment: .trailing) {
                            Rectangle().frame(width: proxy.size.width / 2)
                        }
                case .trailing:
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .overlay(alignment: .leading) {
                            Rectangle().frame(width: proxy.size.width / 2)
                        }
                case .bothSides:
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                case .none:
                    Rectangle()
                }
            }
        }
    }
    
    enum Side {
        case leading
        case trailing
        case bothSides
        case none
        
        var edge: Edge.Set {
            switch self {
            case .leading: return .leading
            case .trailing: return .trailing
            case .bothSides: return .horizontal
            case .none: return .leading
            }
        }
    }
}

extension View {
    func withCornerRadius(_ cornerRadius: CGFloat, at side: WithRoundedCorner.Side) -> some View {
        modifier(WithRoundedCorner(cornerRadius: cornerRadius, at: side))
    }
}
