//
//  CacheStorage.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import Foundation

class CacheStorage: @unchecked Sendable {
    static let shared = CacheStorage()
    
    private var caches: [AnyHashable : any Cacheable] = [:]
    private var lock: NSLock
    
    private init() {
        lock = NSLock()
        self.caches = [:]
    }
    
    func addCache(_ cache: some Cacheable) {
        lock.withLock {
            caches[cache.cacheKey] = cache
        }
    }
    
    func removeCache(_ key: AnyHashable) {
        lock.withLock {
            caches[key] = nil
        }
    }
    
    func withCacheIfAvailable<T: Sendable>(
        _ key: AnyHashable,
        action: @Sendable @escaping (any Cacheable) throws -> T
    ) rethrows -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        if let cache = caches[key] {
            return try action(cache)
        }
        return nil
    }
    
    func withCacheIfAvailable<T: Cacheable & Sendable>(
        _ key: AnyHashable,
        type: T.Type
    ) -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        if let cache = caches[key] {
            return T(fromCache: cache)
        }
        return nil
    }
}
