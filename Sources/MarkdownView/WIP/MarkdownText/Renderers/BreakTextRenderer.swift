//
//  BreakTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct BreakTextRenderer: MarkdownNode2TextRenderer {
    var breakType: BreakType?
    enum BreakType {
        case soft
        case hard
    }
    
    func body(context: Context) -> Text {
        let breakType: BreakType? = switch context.node.kind {
        case .hardBreak: .hard
        case .softBreak: .soft
        default: self.breakType
        }
        
        if breakType == .soft {
            Text(" ")
        } else if breakType == .hard {
            Text("\n")
                .font(.system(size: 1))
        }
    }
}
