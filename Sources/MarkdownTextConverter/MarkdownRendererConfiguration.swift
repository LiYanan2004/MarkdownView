//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/15.
//

import MarkdownPresentation
import SwiftUI
import MarkdownRenderingEssentials
#if canImport(RichText)
import RichText
#endif

package struct MarkdownRendererConfiguration {
    package var preferredBaseURL: URL?
    package var componentSpacing: CGFloat = 12
    
    package var underlineLinks: Bool = false
    
    package var math: Math = Math()
    package var tintColors: [MarkdownTintableComponent : Color] = [:]
    package var listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration()
    package var fonts: [MarkdownComponent: any CustomCTFontConvertible] = [:]
    #if canImport(RichText)
    package var attachmentRenderer: any MarkdownTextAttachmentRenderer
    #endif

    #if canImport(RichText)
    @MainActor
    package init(
        preferredBaseURL: URL? = nil,
        componentSpacing: CGFloat = 12,
        underlineLinks: Bool = false,
        math: Math = Math(),
        tintColors: [MarkdownTintableComponent: Color] = [:],
        listConfiguration: MarkdownListConfiguration = MarkdownListConfiguration(),
        fonts: [MarkdownComponent: any CustomCTFontConvertible] = [:],
        attachmentRenderer: any MarkdownTextAttachmentRenderer = DefaultMarkdownTextAttachmentRenderer()
    ) {
        self.preferredBaseURL = preferredBaseURL
        self.componentSpacing = componentSpacing
        self.underlineLinks = underlineLinks
        self.math = math
        self.tintColors = tintColors
        self.listConfiguration = listConfiguration
        self.fonts = fonts
        self.attachmentRenderer = attachmentRenderer
    }

    @MainActor
    package init(
        presentationConfiguration: MarkdownPresentation.MarkdownRendererConfiguration,
        fonts: [MarkdownComponent: any CustomCTFontConvertible],
        attachmentRenderer: any MarkdownTextAttachmentRenderer = DefaultMarkdownTextAttachmentRenderer()
    ) {
        preferredBaseURL = presentationConfiguration.preferredBaseURL
        componentSpacing = presentationConfiguration.componentSpacing
        underlineLinks = presentationConfiguration.underlineLinks
        math = Math(presentationConfiguration: presentationConfiguration.math)
        tintColors = [:]
        for (component, color) in presentationConfiguration.tintColors {
            switch component {
            case .blockQuote:
                tintColors[.blockQuote] = color
            case .inlineCodeBlock:
                tintColors[.inlineCodeBlock] = color
            case .link:
                tintColors[.link] = color
            }
        }
        listConfiguration = MarkdownListConfiguration(
            presentationConfiguration: presentationConfiguration.listConfiguration
        )
        self.fonts = fonts
        self.attachmentRenderer = attachmentRenderer
    }
    #endif
}

// MARK: - MarkdownTintableComponent

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownTintableComponent")
public typealias TintableComponent = MarkdownRenderingEssentials.MarkdownTintableComponent

public typealias MarkdownTintableComponent = MarkdownRenderingEssentials.MarkdownTintableComponent

// MARK: - SwiftUI Environment

struct MarkdownTextFontsKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: [MarkdownComponent: any CustomCTFontConvertible] = [
        .h1: PlatformFont.preferredFont(forTextStyle: .largeTitle),
        .h2: PlatformFont.preferredFont(forTextStyle: .title1),
        .h3: PlatformFont.preferredFont(forTextStyle: .title2),
        .h4: PlatformFont.preferredFont(forTextStyle: .title3),
        .h5: PlatformFont.preferredFont(forTextStyle: .headline),
        .h6: PlatformFont.systemFont(
            ofSize: PlatformFont.preferredFont(forTextStyle: .headline).pointSize,
            weight: .regular
        ),
        .body: PlatformFont.preferredFont(forTextStyle: .body),
        .codeBlock: PlatformFont.monospacedSystemFont(
            ofSize: PlatformFont.preferredFont(forTextStyle: .callout).pointSize,
            weight: .regular
        ),
        .blockQuote: PlatformFont.preferredFont(forTextStyle: .body),
        .tableHeader: PlatformFont.preferredFont(forTextStyle: .headline),
        .tableBody: PlatformFont.preferredFont(forTextStyle: .body),
        .inlineMath: PlatformFont.preferredFont(forTextStyle: .body),
        .displayMath: PlatformFont.preferredFont(forTextStyle: .body),
    ]
}

extension EnvironmentValues {
    package var markdownTextFonts: [MarkdownComponent: any CustomCTFontConvertible] {
        get { self[MarkdownTextFontsKey.self] }
        set { self[MarkdownTextFontsKey.self] = newValue }
    }
}
