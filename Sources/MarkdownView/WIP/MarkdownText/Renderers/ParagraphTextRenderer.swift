//
//  ParagraphTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct ParagraphTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        if context.node.index != 0 {
            BreakTextRenderer(breakType: .hard)
                .body(context: context)
        }
        context.node.children
            .map { $0.render(configuration: context.renderConfiguration) }
            .reduce(Text(""), +)
    }
}
