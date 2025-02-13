//
//  OrderedListTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/13.
//

import SwiftUI

struct OrderedListTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        BreakTextRenderer(breakType: .hard)
            .body(context: context)
        
        let listConfiguration = context.renderConfiguration.listConfiguration
        let marker = Text("\(listConfiguration.orderedListMarker.marker(at: context.node.depth ?? 0)) ")
            .font(.body.monospaced())
        
        context.node.children
            .map { $0.render(configuration: context.renderConfiguration) }
            .reduce(Text("")) { list, item in
                list + marker + item
            }
    }
}
