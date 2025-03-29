//
//  Cachable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import Foundation

protocol Cachable: Sendable {
    associatedtype CacheKey: Hashable
    var cacheKey: CacheKey { get }
    
    init?(fromCache value: any Cachable)
}

extension Cachable {
    init?(fromCache value: any Cachable) {
        guard let value = value as? Self else { return nil }
        self = value
    }
}
