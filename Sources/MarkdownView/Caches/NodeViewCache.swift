//
//  NodeViewCache.swift
//  MarkdownView
//
//  Created for streaming markdown rendering optimization
//

import SwiftUI
import Markdown

/// Cache entry for a single rendered markdown node
struct NodeCacheEntry: Cacheable {
    typealias CacheKey = NodeCacheKey

    let cacheKey: NodeCacheKey
    let renderedView: MarkdownNodeView
    let lastAccessTime: Date

    init(key: NodeCacheKey, view: MarkdownNodeView) {
        self.cacheKey = key
        self.renderedView = view
        self.lastAccessTime = Date()
    }

    /// Update access time for LRU tracking
    func accessed() -> NodeCacheEntry {
        NodeCacheEntry(
            key: cacheKey,
            view: renderedView
        )
    }
}

/// Cache key based on node content and rendering configuration
struct NodeCacheKey: Hashable {
    let contentHash: Int
    let configurationHash: Int

    init(node: some Markup, configuration: MarkdownRendererConfiguration) {
        self.contentHash = node.stableContentHash
        self.configurationHash = configuration.hashValue
    }

    init(contentHash: Int, configHash: Int) {
        self.contentHash = contentHash
        self.configurationHash = configHash
    }
}

/// Thread-safe LRU cache for rendered markdown nodes
/// Optimized for streaming scenarios where most nodes remain unchanged
@MainActor
class NodeViewCache {
    private var cache: [NodeCacheKey: NodeCacheEntry] = [:]
    private var accessOrder: [NodeCacheKey] = []
    private let maxSize: Int

    // Statistics for performance monitoring
    private(set) var hits: Int = 0
    private(set) var misses: Int = 0

    init(maxSize: Int = 1000) {
        self.maxSize = maxSize
    }

    /// Retrieve a cached view for a node
    func get(for node: some Markup, configuration: MarkdownRendererConfiguration) -> MarkdownNodeView? {
        let key = NodeCacheKey(node: node, configuration: configuration)

        if let entry = cache[key] {
            // Update LRU access order
            moveToFront(key)
            hits += 1
            return entry.renderedView
        }

        misses += 1
        return nil
    }

    /// Store a rendered view in the cache
    func set(_ view: MarkdownNodeView, for node: some Markup, configuration: MarkdownRendererConfiguration) {
        let key = NodeCacheKey(node: node, configuration: configuration)
        let entry = NodeCacheEntry(key: key, view: view)

        cache[key] = entry
        moveToFront(key)

        // Evict oldest entries if over capacity
        if accessOrder.count > maxSize {
            evictLRU()
        }
    }

    /// Remove all cached entries
    func clear() {
        cache.removeAll()
        accessOrder.removeAll()
        hits = 0
        misses = 0
    }

    /// Get cache statistics
    var hitRate: Double {
        let total = hits + misses
        guard total > 0 else { return 0.0 }
        return Double(hits) / Double(total)
    }

    var size: Int {
        cache.count
    }

    // MARK: - Private LRU Implementation

    private func moveToFront(_ key: NodeCacheKey) {
        // Remove from current position
        accessOrder.removeAll { $0 == key }
        // Add to front (most recently used)
        accessOrder.insert(key, at: 0)
    }

    private func evictLRU() {
        // Remove least recently used items (from the back)
        let evictionCount = accessOrder.count - maxSize
        guard evictionCount > 0 else { return }

        let keysToEvict = accessOrder.suffix(evictionCount)
        for key in keysToEvict {
            cache.removeValue(forKey: key)
        }
        accessOrder.removeLast(evictionCount)
    }
}

// MARK: - Debug Statistics

extension NodeViewCache {
    /// Print cache statistics for debugging
    func printStatistics() {
        print("""
        NodeViewCache Statistics:
        - Size: \(size)/\(maxSize)
        - Hit Rate: \(String(format: "%.1f%%", hitRate * 100))
        - Hits: \(hits)
        - Misses: \(misses)
        """)
    }
}
