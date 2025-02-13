//
//  InlineCodeTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct InlineCodeTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        if case let .text(text) = context.node.content! {
            Text(text).font(.body.monospaced())
        }
    }
}
