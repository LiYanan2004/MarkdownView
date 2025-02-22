//
//  LinkTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct LinkTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        if case let .link(title, url) = context.node.content! {
            Text(.init("[\(title)](\(url))"))
        }
    }
}
