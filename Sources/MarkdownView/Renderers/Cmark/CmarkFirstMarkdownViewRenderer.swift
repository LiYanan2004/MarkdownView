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
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        _makeAndCacheBody(
            content: content,
            configuration: configuration
        )
    }
    
    private func _makeAndCacheBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        if let cached = CacheStorage.shared.withCacheIfAvailable(
            content,
            type: Cache.self
        ), cached.configuration == configuration {
            return AnyView(cached.renderedView)
        }
        
        let renderedView = CmarkNodeVisitor(configuration: configuration)
            .makeBody(for: content.parse(options: parseOptions(for: configuration)))
            .erasedToAnyView()
        
        CacheStorage.shared.addCache(
            Cache(
                markdownContent: content,
                configuration: configuration,
                renderedView: renderedView
            )
        )
        
        return renderedView
    }
}

fileprivate extension CmarkFirstMarkdownViewRenderer {
    func parseOptions(for configuration: MarkdownRendererConfiguration) -> ParseOptions {
        var parseOptions = ParseOptions()
        if !configuration.allowedBlockDirectiveRenderers.isEmpty {
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
