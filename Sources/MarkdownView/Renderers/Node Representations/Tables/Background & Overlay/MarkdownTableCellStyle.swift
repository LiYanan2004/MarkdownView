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
    
    var size: CGSize
    var width: CGFloat {
        size.width
    }
    var height: CGFloat {
        size.height
    }
    
    var backgroundStyle: AnyShapeStyle? = nil
    var backgroundShape: any Shape = .rect
    var overlayContent: AnyView? = nil
    
    init(position: Position, size: CGSize) {
        self.position = position
        self.size = size
    }
    
    init(position: Position, width: CGFloat, height: CGFloat) {
        self.position = position
        self.size = CGSize(width: width, height: height)
    }
}
