//
//  MarkdownTableCellStyle.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

struct MarkdownTableCellStyle: Identifiable {
    struct Position: Hashable {
        var column: Int
        var row: Int
    }
    var position: Position
    var id: Position { position }
    
    var rect: CGRect
    var width: CGFloat {
        rect.width
    }
    var height: CGFloat {
        rect.height
    }
    
    var backgroundStyle: AnyShapeStyle? = nil
    var backgroundShape: any Shape = .rect
    var overlayContent: AnyView? = nil
    
    init(position: Position, rect: CGRect) {
        self.position = position
        self.rect = rect
    }
}
