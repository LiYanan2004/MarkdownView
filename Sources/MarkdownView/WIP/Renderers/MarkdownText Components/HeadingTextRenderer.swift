//
//  HeadingTextRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

struct HeadingTextRenderer: MarkdownNode2TextRenderer {
    func body(context: Context) -> Text {
        let level = if case let .heading(level) = context.node.content {
            level
        } else {
            -1
        }
        
        let font = switch level {
        case 1: context.renderConfiguration.fontGroup.h1
        case 2: context.renderConfiguration.fontGroup.h2
        case 3: context.renderConfiguration.fontGroup.h3
        case 4: context.renderConfiguration.fontGroup.h4
        case 5: context.renderConfiguration.fontGroup.h5
        case 6: context.renderConfiguration.fontGroup.h6
        default: context.renderConfiguration.fontGroup.body
        }
        
        let foregroundStyle = switch level {
        case 1: context.renderConfiguration.foregroundStyleGroup.h1
        case 2: context.renderConfiguration.foregroundStyleGroup.h2
        case 3: context.renderConfiguration.foregroundStyleGroup.h3
        case 4: context.renderConfiguration.foregroundStyleGroup.h4
        case 5: context.renderConfiguration.foregroundStyleGroup.h5
        case 6: context.renderConfiguration.foregroundStyleGroup.h6
        default: AnyShapeStyle(.foreground)
        }
        
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            context.node.children
                .map { $0.render(configuration: context.renderConfiguration) }
                .reduce(Text(""), +)
                .foregroundStyle(foregroundStyle)
                .font(font)
        } else {
            context.node.children
                .map { $0.render(configuration: context.renderConfiguration) }
                .reduce(Text(""), +)
                .font(font)
        }
        
        BreakTextRenderer(breakType: .hard)
            .body(context: context)
    }
}
