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
        case 1: context.environment.markdownRendererConfiguration.fontGroup.h1
        case 2: context.environment.markdownRendererConfiguration.fontGroup.h2
        case 3: context.environment.markdownRendererConfiguration.fontGroup.h3
        case 4: context.environment.markdownRendererConfiguration.fontGroup.h4
        case 5: context.environment.markdownRendererConfiguration.fontGroup.h5
        case 6: context.environment.markdownRendererConfiguration.fontGroup.h6
        default: context.environment.markdownRendererConfiguration.fontGroup.body
        }
        
        let foregroundStyle = switch level {
        case 1: context.environment.headingStyleGroup.h1
        case 2: context.environment.headingStyleGroup.h2
        case 3: context.environment.headingStyleGroup.h3
        case 4: context.environment.headingStyleGroup.h4
        case 5: context.environment.headingStyleGroup.h5
        case 6: context.environment.headingStyleGroup.h6
        default: AnyShapeStyle(.foreground)
        }
        
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
            context.node.children
                .map { $0.render() }
                .reduce(Text(""), +)
                .foregroundStyle(foregroundStyle)
                .font(font)
        } else {
            context.node.children
                .map { $0.render() }
                .reduce(Text(""), +)
                .font(font)
        }
        
        BreakTextRenderer(breakType: .hard)
            .body(context: context)
    }
}
