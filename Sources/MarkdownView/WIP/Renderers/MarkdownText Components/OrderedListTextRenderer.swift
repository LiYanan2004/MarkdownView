//
//  OrderedListTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/13.
//

import SwiftUI

struct OrderedListTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        let indents = context.node.depth ?? 0
        let indentation = (0..<indents).reduce(Text("")) { indent, _ in
            indent + Text("\t")
        }
        
        context.node.children
            .map { $0.render(configuration: context.renderConfiguration) }
            .enumerated()
            .reduce(Text("")) { list, enumeratedItem in
                let (offset, listItem) = enumeratedItem
                let marker = markerText(context: context, index: offset)
                return list + indentation + marker + listItem
            }
    }
    
    @TextBuilder
    private func markerText(context: Context, index: Int) -> Text {
        let marker = context.renderConfiguration.listConfiguration
            .orderedListMarker
            .marker(at: index, listDepth: context.node.depth ?? 0)
        if context.renderConfiguration.listConfiguration.orderedListMarker.monospaced {
            if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                Text("\(marker) ")
                    .monospaced()
            } else {
                Text("\(marker) ")
                    .font(.body.monospaced())
            }
        } else {
            Text("\(marker) ")
        }
    }
}
