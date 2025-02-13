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
            if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                Text(text).monospaced()
            } else {
                Text(text).font(.body.monospaced())
            }
        }
    }
}
