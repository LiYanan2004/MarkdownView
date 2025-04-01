//
//  Cacheable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import Foundation

protocol Cacheable {
    associatedtype CacheKey: Hashable
    var cacheKey: CacheKey { get }
    
    init?(fromCache value: any Cacheable)
}

extension Cacheable {
    init?(fromCache value: any Cacheable) {
        guard let value = value as? Self else { return nil }
        self = value
    }
}
