//
//  MarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

public protocol MarkdownViewRenderer {
    associatedtype Body: SwiftUI.View
    
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> Body
}

public struct AutomaticMarkdownViewRenderer: MarkdownViewRenderer {
    public init() {}
    
    @ViewBuilder
    public func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        #if canImport(RichText)
        if #available(iOS 26.0, macOS 26.0, *) {
            TextContentMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration)
        } else {
            ViewMarkdownViewRenderer()
                .makeBody(content: content, configuration: configuration)
        }
        #else
        ViewMarkdownViewRenderer()
            .makeBody(content: content, configuration: configuration)
        #endif
    }
}

public struct ViewMarkdownViewRenderer: MarkdownViewRenderer {
    public init() {}
    
    @ViewBuilder
    public func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        if configuration.rendersMath {
            MathFirstMarkdownViewRenderer().makeBody(
                content: content,
                configuration: configuration
            )
        } else {
            CmarkFirstMarkdownViewRenderer().makeBody(
                content: content,
                configuration: configuration
            )
        }
    }
}

#if canImport(RichText)
@available(iOS 26, macOS 26, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct TextContentMarkdownViewRenderer: MarkdownViewRenderer {
    public init() {}
    
    @ViewBuilder
    public func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        if configuration.rendersMath {
            MathFirstTextViewRenderer().makeBody(
                content: content,
                configuration: configuration
            )
        } else {
            TextViewViewRenderer().makeBody(
                content: content,
                configuration: configuration
            )
        }
    }
}
#endif

public extension MarkdownViewRenderer where Self == AutomaticMarkdownViewRenderer {
    static var automatic: AutomaticMarkdownViewRenderer { .init() }
}

public extension MarkdownViewRenderer where Self == ViewMarkdownViewRenderer {
    static var view: ViewMarkdownViewRenderer { .init() }
}

#if canImport(RichText)
@available(iOS 26, macOS 26, *)
public extension MarkdownViewRenderer where Self == TextContentMarkdownViewRenderer {
    static var textContent: TextContentMarkdownViewRenderer { .init() }
}
#endif

extension MarkdownViewRenderer {
    internal func parseOptions(for configuration: MarkdownRendererConfiguration) -> ParseOptions {
        var options = ParseOptions()
        
        if !configuration.allowedBlockDirectiveRenderers.isEmpty {
            options.insert(.parseBlockDirectives)
        }
        
        return options
    }
}

struct MarkdownViewRendererKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: any MarkdownViewRenderer = .automatic
}

extension EnvironmentValues {
    var markdownViewRenderer: any MarkdownViewRenderer {
        get { self[MarkdownViewRendererKey.self] }
        set { self[MarkdownViewRendererKey.self] = newValue }
    }
}
