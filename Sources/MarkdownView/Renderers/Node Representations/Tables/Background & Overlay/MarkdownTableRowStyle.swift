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
    
    var idealHeight: CGFloat
    
    var backgroundStyle: AnyShapeStyle? = nil
    var backgroundShape: any Shape = .rect
    
    init(position: Position, idealHeight: CGFloat) {
        self.position = position
        self.idealHeight = idealHeight
    }
}
