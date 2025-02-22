//
//  UnorderedListTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/13.
//

import SwiftUI

struct UnorderedListTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        let indents = context.node.depth ?? 0
        let indentation = (0..<indents).reduce(Text("")) { indent, _ in
            indent + Text("\t")
        }
        
        context.node.children
            .map { $0.render(configuration: context.renderConfiguration) }
            .reduce(Text("")) { list, listItem in
                let marker = markerText(context: context)
                return list + indentation + marker + listItem
            }
    }
    
    @TextBuilder
    private func markerText(context: Context) -> Text {
        let marker = context.renderConfiguration.listConfiguration
            .unorderedListMarker
            .marker(listDepth: context.node.depth ?? 0)
        if context.renderConfiguration.listConfiguration.unorderedListMarker.monospaced {
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
