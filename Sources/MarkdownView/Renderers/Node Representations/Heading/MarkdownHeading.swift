//
//  MarkdownHeading.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

struct MarkdownHeading: View {
    let heading: Heading
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.headingStyleGroup) private var headingStyleGroup
    @Environment(\.headingPaddings) private var paddings
    
    private var font: Font {
        let fontProvider = configuration.fontGroup
        return switch heading.level {
        case 1: fontProvider.h1
        case 2: fontProvider.h2
        case 3: fontProvider.h3
        case 4: fontProvider.h4
        case 5: fontProvider.h5
        case 6: fontProvider.h6
        default: fontProvider.body
        }
    }
    private var foregroundStyle: AnyShapeStyle {
        return switch heading.level {
        case 1: headingStyleGroup.h1
        case 2: headingStyleGroup.h2
        case 3: headingStyleGroup.h3
        case 4: headingStyleGroup.h4
        case 5: headingStyleGroup.h5
        case 6: headingStyleGroup.h6
        default: AnyShapeStyle(.foreground)
        }
    }
    
    var body: some View {
        let id = heading.range?.description ?? "Unknown Range"
        CmarkNodeVisitor(configuration: configuration)
            .descendInto(heading)
            .id(id)
            .padding(paddings[heading.level])
            .foregroundStyle(foregroundStyle)
            .font(font)
            .accessibilityAddTraits(.isHeader)
    }
}
