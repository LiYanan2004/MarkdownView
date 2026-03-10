//
//  MarkdownSubtreeRenderer.swift
//  MarkdownView
//
//  Created by Codex on 2026/2/6.
//

import SwiftUI
import Markdown

struct MarkdownSubtreeRenderer {
    private let renderMarkup: @MainActor (any Markup, MarkdownRendererConfiguration) -> AnyView
    private let renderChildren: @MainActor (any Markup, MarkdownRendererConfiguration) -> AnyView
    
    init(
        renderMarkup: @escaping @MainActor (any Markup, MarkdownRendererConfiguration) -> AnyView,
        renderChildren: @escaping @MainActor (any Markup, MarkdownRendererConfiguration) -> AnyView
    ) {
        self.renderMarkup = renderMarkup
        self.renderChildren = renderChildren
    }
    
    @MainActor
    @ViewBuilder
    func makeBody(
        for markup: any Markup,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        renderMarkup(markup, configuration)
    }
    
    @MainActor
    @ViewBuilder
    func makeBody(
        descendingInto markup: any Markup,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        renderChildren(markup, configuration)
    }
    
    static let pipelineBacked: MarkdownSubtreeRenderer = MarkdownSubtreeRenderer(
        renderMarkup: { markup, configuration in
            MarkdownRenderPipeline(configuration: configuration)
                .makeViewBody(for: markup)
        },
        renderChildren: { markup, configuration in
            MarkdownRenderPipeline(configuration: configuration)
                .makeViewBody(descendingInto: markup)
        }
    )
}

struct MarkdownSubtreeRendererKey: EnvironmentKey {
    static let defaultValue: MarkdownSubtreeRenderer = .pipelineBacked
}

extension EnvironmentValues {
    var markdownSubtreeRenderer: MarkdownSubtreeRenderer {
        get { self[MarkdownSubtreeRendererKey.self] }
        set { self[MarkdownSubtreeRendererKey.self] = newValue }
    }
}
