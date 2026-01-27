//
//  Cacheable.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import Foundation

protocol Cacheable {
    associatedtype Key: Hashable
    var cacheKey: Key { get }
    
    init?(fromCache value: any Cacheable)
}

extension Cacheable {
    init?(fromCache value: any Cacheable) {
        guard let value = value as? Self else { return nil }
        self = value
    }
}
