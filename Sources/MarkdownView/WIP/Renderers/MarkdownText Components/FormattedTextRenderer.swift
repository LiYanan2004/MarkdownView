//
//  File.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct FormattedTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        let text = context.node.children
            .map { $0.render(configuration: context.renderConfiguration) }
            .reduce(Text(""), +)
        
        return switch context.node.kind {
        case .boldText:
            text.bold()
        case .italicText:
            text.italic()
        case .strikethrough:
            text.strikethrough()
        default:
            fatalError()
        }
    }
}
