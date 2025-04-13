//
//  CmarkFirstMarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI

struct CmarkFirstMarkdownViewRenderer: MarkdownViewRenderer {    
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRenderConfiguration
    ) -> some View {
        _makeAndCacheBody(
            content: content,
            configuration: configuration
        )
    }
    
    private func _makeAndCacheBody(
        content: MarkdownContent,
        configuration: MarkdownRenderConfiguration
    ) -> some View {
        if let cached = CacheStorage.shared.withCacheIfAvailable(
            content,
            type: Cache.self
        ), cached.configuration == configuration {
            return AnyView(cached.renderedView)
        }
        
        let renderedView = CmarkNodeVisitor(
            configuration: configuration
        ).makeBody(for: content.document).erasedToAnyView()
        
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

extension CmarkFirstMarkdownViewRenderer {
    struct Cache: Cacheable {
        var markdownContent: MarkdownContent
        var configuration: MarkdownRenderConfiguration
        var renderedView: any View
        
        var cacheKey: some Hashable { markdownContent }
    }
}
