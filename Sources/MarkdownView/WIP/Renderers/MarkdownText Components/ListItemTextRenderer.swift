//
//  ListItemTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/13.
//

import SwiftUI

struct ListItemTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        context.node.children
            .map { $0.render() }
            .reduce(Text(""), +)
    }
}
