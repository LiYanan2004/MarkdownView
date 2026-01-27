//
//  HeadingText.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

struct HeadingText: View {
    let heading: Heading
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.headingStyleGroup) private var headingStyleGroup
    @Environment(\.headingPaddings) private var paddings
    
    private var font: Font {
        return switch heading.level {
        case 1: configuration.fonts[.h1] ?? .largeTitle
        case 2: configuration.fonts[.h2] ?? .title
        case 3: configuration.fonts[.h3] ?? .title2
        case 4: configuration.fonts[.h4] ?? .title3
        case 5: configuration.fonts[.h5] ?? .headline
        case 6: configuration.fonts[.h6] ?? .headline.weight(.regular)
        default: configuration.fonts[.body] ?? .body
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
