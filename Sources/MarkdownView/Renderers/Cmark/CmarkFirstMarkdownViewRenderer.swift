//
//  CmarkFirstMarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

struct CmarkFirstMarkdownViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        _makeAndCacheBody(
            content: content,
            configuration: configuration,
            elementRenderers: elementRenderers
        )
    }
    
    private func _makeAndCacheBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration,
        elementRenderers: [MarkdownElementRendererRegistration]
    ) -> some View {
        if elementRenderers.isEmpty,
           let cached = CacheStorage.shared.withCacheIfAvailable(
            content,
            type: Cache.self
        ), cached.configuration == configuration {
            return AnyView(cached.renderedView)
        }
        
        let visitor = CmarkNodeVisitor(
            configuration: configuration,
            elementRenderers: elementRenderers
        )
        let renderedView = visitor
            .makeBody(for: content.parse(options: parseOptions(for: elementRenderers)))
            .erasedToAnyView()
        
        if elementRenderers.isEmpty {
            CacheStorage.shared.addCache(
                Cache(
                    markdownContent: content,
                    configuration: configuration,
                    renderedView: renderedView
                )
            )
        }
        
        return renderedView
    }
}

fileprivate extension CmarkFirstMarkdownViewRenderer {
    func parseOptions(for elementRenderers: [MarkdownElementRendererRegistration]) -> ParseOptions {
        var parseOptions = ParseOptions()
        if elementRenderers.contains(where: { $0.blockDirective != nil }) {
            parseOptions.insert(.parseBlockDirectives)
        }
        return parseOptions
    }
}

extension CmarkFirstMarkdownViewRenderer {
    struct Cache: Cacheable {
        var markdownContent: MarkdownContent
        var configuration: MarkdownRendererConfiguration
        var renderedView: any View
        
        var cacheKey: some Hashable { markdownContent }
    }
}
