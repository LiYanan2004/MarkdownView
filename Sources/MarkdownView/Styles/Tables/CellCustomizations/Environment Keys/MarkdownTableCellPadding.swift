//
//  MarkdownTableCellPadding.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/20.
//

import SwiftUI

struct MarkdownTableCellPadding: Sendable {
    private init() { }
    static let zero = MarkdownTableCellPadding()
    
    private var amounts: [Edge : CGFloat] = [:]
    
    init(_ edges: Edge.Set, amount: CGFloat) {
        var amounts = [Edge : CGFloat]()
        
        if edges.contains(.top) {
            amounts[.top] = amount
        }
        
        if edges.contains(.bottom) {
            amounts[.bottom] = amount
        }
        
        if edges.contains(.leading) {
            amounts[.leading] = amount
        }
        
        if edges.contains(.trailing) {
            amounts[.trailing] = amount
        }
        
        self.amounts = amounts
    }
    
    subscript(_ edge: Edge) -> CGFloat {
        amounts[edge] ?? .zero
    }
    
    mutating func merge(_ padding: MarkdownTableCellPadding) {
        amounts.merge(padding.amounts, uniquingKeysWith: { $1 })
    }
}

// MARK: - Environment Values

struct MarkdownTableCellPaddingEnvironmentKey: EnvironmentKey {
    static let defaultValue: MarkdownTableCellPadding = .init(.all, amount: 8)
}

extension EnvironmentValues {
    var markdownTableCellPadding: MarkdownTableCellPadding {
        get { self[MarkdownTableCellPaddingEnvironmentKey.self] }
        set { self[MarkdownTableCellPaddingEnvironmentKey.self].merge(newValue) }
    }
}
