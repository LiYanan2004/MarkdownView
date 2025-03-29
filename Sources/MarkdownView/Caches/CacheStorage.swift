//
//  CacheStorage.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import Foundation

actor CacheStorage: Sendable {
    static var shared = CacheStorage()
    
    private init() {
        self.caches = [:]
    }
    
    private var caches: [AnyHashable : any Cachable] = [:]
    
    func addCache(_ cache: some Cachable) {
        caches[cache.cacheKey] = cache
    }
    
    func withCacheIfAvailable<T>(
        _ key: AnyHashable,
        action: @Sendable @escaping (any Cachable) throws -> T
    ) rethrows -> T? {
        if let cache = caches[key] {
            return try action(cache)
        }
        return nil
    }
    
    func removeCache(_ key: AnyHashable) {
        caches[key] = nil
    }
}
