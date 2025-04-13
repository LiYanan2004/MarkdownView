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
    var shouldAddAdditionalSpacing: Bool
    
    @Environment(\.markdownRendererConfiguration) private var configuration
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
        let styleProvider = configuration.foregroundStyleGroup
        return switch heading.level {
        case 1: styleProvider.h1
        case 2: styleProvider.h2
        case 3: styleProvider.h3
        case 4: styleProvider.h4
        case 5: styleProvider.h5
        case 6: styleProvider.h6
        default: AnyShapeStyle(.foreground)
        }
    }
    
    var body: some View {
        let id = heading.range?.description ?? "Unknown Range"
        CmarkNodeVisitor(configuration: configuration)
            .descendInto(heading)
            .id(id)
            .padding(.top, shouldAddAdditionalSpacing ? nil : 0)
            .foregroundStyle(foregroundStyle)
            .font(font)
            .accessibilityAddTraits(.isHeader)
    }
}
