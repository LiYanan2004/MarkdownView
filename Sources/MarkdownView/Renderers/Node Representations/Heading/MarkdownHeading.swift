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
    @Environment(\.markdownFontGroup) private var fontGroup
    @Environment(\.headingStyleGroup) private var headingStyleGroup
    @Environment(\.headingPaddings) private var paddings
    
    private var font: Font {
        return switch heading.level {
        case 1: fontGroup.h1
        case 2: fontGroup.h2
        case 3: fontGroup.h3
        case 4: fontGroup.h4
        case 5: fontGroup.h5
        case 6: fontGroup.h6
        default: fontGroup.body
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
    private var accessibilityHeadingLevel: AccessibilityHeadingLevel {
        return switch heading.level {
        case 1: .h1
        case 2: .h2
        case 3: .h3
        case 4: .h4
        case 5: .h5
        case 6: .h6
        default: .unspecified
        }
    }
    
    var body: some View {
        CmarkNodeVisitor(configuration: configuration)
            .descendInto(heading)
            .font(font)
            .foregroundStyle(foregroundStyle)
            .accessibilityHeading(accessibilityHeadingLevel)
            .padding(paddings[heading.level])
            .accessibilityAddTraits(.isHeader)
    }
}
