//
//  UnorderedListTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/13.
//

import SwiftUI

struct UnorderedListTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        let listConfiguration = context.renderConfiguration.listConfiguration
        let marker = Text("\(listConfiguration.unorderedListMarker.marker(at: context.node.depth ?? 0)) ")
            .font(.body.monospaced())
        
        let lineBreak = BreakTextRenderer(breakType: .hard)
            .body(context: context)
        let indents = context.node.depth ?? 0
        let indentation = (0..<indents).reduce(Text("")) { indent, _ in
            indent + Text("\t")
        }
        
        context.node.children
            .map { $0.render(configuration: context.renderConfiguration) }
            .reduce(Text("")) { list, item in
                list + lineBreak + indentation + marker + item
            }
    }
}
