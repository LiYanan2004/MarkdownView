//
//  MarkdownTableRowStyle.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableRowStyle: Identifiable {
    struct Position: Hashable {
        var column: Int
        var row: Int
    }
    var position: Position
    var id: Position { position }
    
    var minY: CGFloat
    var maxY: CGFloat
    
    var backgroundStyle: AnyShapeStyle? = nil
    var backgroundShape: any Shape = .rect
    
    init(position: Position, minY: CGFloat, maxY: CGFloat) {
        self.position = position
        self.minY = minY
        self.maxY = maxY
    }
}
