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
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> Body
}

public struct AutomaticMarkdownViewRenderer: MarkdownViewRenderer {
    public init() {}
    
    @ViewBuilder
    public func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        #if canImport(RichText)
        if #available(iOS 26.0, macOS 26.0, *) {
            TextContentMarkdownViewRenderer()
                .makeBody(
                    content: content,
                    configuration: configuration,
                    elementRenderers: elementRenderers
                )
        } else {
            ViewMarkdownViewRenderer()
                .makeBody(
                    content: content,
                    configuration: configuration,
                    elementRenderers: elementRenderers
                )
        }
        #else
        ViewMarkdownViewRenderer()
            .makeBody(
                content: content,
                configuration: configuration,
                elementRenderers: elementRenderers
            )
        #endif
    }
}

public struct ViewMarkdownViewRenderer: MarkdownViewRenderer {
    public init() {}
    
    @ViewBuilder
    public func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        if configuration.rendersMath {
            MathFirstMarkdownViewRenderer().makeBody(
                content: content,
                configuration: configuration,
                elementRenderers: elementRenderers
            )
        } else {
            CmarkFirstMarkdownViewRenderer().makeBody(
                content: content,
                configuration: configuration,
                elementRenderers: elementRenderers
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
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        if configuration.rendersMath {
            MathFirstTextViewRenderer().makeBody(
                content: content,
                configuration: configuration,
                elementRenderers: elementRenderers
            )
        } else {
            TextViewViewRenderer().makeBody(
                content: content,
                configuration: configuration,
                elementRenderers: elementRenderers
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
    internal func parseOptions(for elementRenderers: [MarkdownElementRendererRegistration]) -> ParseOptions {
        var options = ParseOptions()
        
        if elementRenderers.contains(where: { $0.blockDirective != nil }) {
            options.insert(.parseBlockDirectives)
        }
        
        return options
    }
}

public struct MarkdownViewRendererKey: EnvironmentKey {
    nonisolated(unsafe) public static let defaultValue: any MarkdownViewRenderer = .automatic
}

public extension EnvironmentValues {
    var markdownViewRenderer: any MarkdownViewRenderer {
        get { self[MarkdownViewRendererKey.self] }
        set { self[MarkdownViewRendererKey.self] = newValue }
    }
}
