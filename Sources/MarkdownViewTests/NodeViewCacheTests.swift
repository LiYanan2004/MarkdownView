//
//  NodeViewCacheTests.swift
//  MarkdownView
//
//  Tests for node-level view caching with LRU eviction
//

import Testing
import SwiftUI
@preconcurrency import Markdown
@testable import MarkdownView

@MainActor
struct NodeViewCacheTests {

    // MARK: - Basic Cache Operations

    @Test("Cache stores and retrieves views")
    func testStoreAndRetrieve() {
        let cache = NodeViewCache(maxSize: 10)
        let doc = Document(parsing: "# Heading")
        let config = MarkdownRendererConfiguration()

        guard let heading = Array(doc.children).first else {
            Issue.record("No heading found")
            return
        }

        // Initially should be a miss
        #expect(cache.get(for: heading, configuration: config) == nil)
        #expect(cache.misses == 1)

        // Create and store a view
        let view = MarkdownNodeView(Text("Test"))
        cache.set(view, for: heading, configuration: config)

        // Should now be a hit
        let retrieved = cache.get(for: heading, configuration: config)
        #expect(retrieved != nil)
        #expect(cache.hits == 1)
    }

    @Test("Cache hit rate calculations")
    func testHitRateCalculation() {
        let cache = NodeViewCache(maxSize: 10)
        let doc = Document(parsing: "Para 1\n\nPara 2\n\nPara 3")
        let config = MarkdownRendererConfiguration()
        let children = Array(doc.children)

        // All misses initially
        for child in children {
            _ = cache.get(for: child, configuration: config)
        }
        #expect(cache.hits == 0)
        #expect(cache.misses == 3)
        #expect(cache.hitRate == 0.0)

        // Store views
        for child in children {
            let view = MarkdownNodeView(Text("Test"))
            cache.set(view, for: child, configuration: config)
        }

        // All hits now
        for child in children {
            _ = cache.get(for: child, configuration: config)
        }
        #expect(cache.hits == 3)
        #expect(cache.misses == 3)
        #expect(cache.hitRate == 0.5) // 3 hits / 6 total = 50%
    }

    @Test("Cache respects configuration changes")
    func testConfigurationSensitivity() {
        let cache = NodeViewCache(maxSize: 10)
        let doc = Document(parsing: "# Heading")
        let config1 = MarkdownRendererConfiguration()
        var config2 = MarkdownRendererConfiguration()
        config2.componentSpacing = 16 // Different from default

        guard let heading = Array(doc.children).first else {
            Issue.record("No heading found")
            return
        }

        // Store with config1
        let view = MarkdownNodeView(Text("Test"))
        cache.set(view, for: heading, configuration: config1)

        // Should hit with config1
        #expect(cache.get(for: heading, configuration: config1) != nil)

        // Should miss with config2 (different configuration)
        #expect(cache.get(for: heading, configuration: config2) == nil)
    }

    // MARK: - LRU Eviction

    @Test("LRU eviction when capacity exceeded")
    func testLRUEviction() {
        let cache = NodeViewCache(maxSize: 3)
        let config = MarkdownRendererConfiguration()

        // Create 4 different nodes
        let doc = Document(parsing: "A\n\nB\n\nC\n\nD")
        let children = Array(doc.children)
        #expect(children.count == 4)

        // Add first 3 nodes
        for (index, child) in children.prefix(3).enumerated() {
            let view = MarkdownNodeView(Text("Node \(index)"))
            cache.set(view, for: child, configuration: config)
        }

        #expect(cache.size == 3)

        // Add 4th node, should evict oldest (first)
        let view4 = MarkdownNodeView(Text("Node 3"))
        cache.set(view4, for: children[3], configuration: config)

        #expect(cache.size == 3) // Still at max size

        // First node should be evicted
        #expect(cache.get(for: children[0], configuration: config) == nil)

        // Other nodes should still be cached
        #expect(cache.get(for: children[1], configuration: config) != nil)
        #expect(cache.get(for: children[2], configuration: config) != nil)
        #expect(cache.get(for: children[3], configuration: config) != nil)
    }

    @Test("Access updates LRU order")
    func testAccessUpdatesLRU() {
        let cache = NodeViewCache(maxSize: 2)
        let config = MarkdownRendererConfiguration()
        let doc = Document(parsing: "A\n\nB\n\nC")
        let children = Array(doc.children)

        // Add A and B
        cache.set(MarkdownNodeView(Text("A")), for: children[0], configuration: config)
        cache.set(MarkdownNodeView(Text("B")), for: children[1], configuration: config)

        #expect(cache.size == 2)

        // Access A (moves it to front)
        _ = cache.get(for: children[0], configuration: config)

        // Add C (should evict B, not A)
        cache.set(MarkdownNodeView(Text("C")), for: children[2], configuration: config)

        #expect(cache.size == 2)

        // A should still be cached
        #expect(cache.get(for: children[0], configuration: config) != nil)

        // B should be evicted
        #expect(cache.get(for: children[1], configuration: config) == nil)

        // C should be cached
        #expect(cache.get(for: children[2], configuration: config) != nil)
    }

    // MARK: - Cache Clear

    @Test("Cache clear removes all entries")
    func testCacheClear() {
        let cache = NodeViewCache(maxSize: 10)
        let config = MarkdownRendererConfiguration()
        let doc = Document(parsing: "A\n\nB\n\nC")

        // Add some entries
        for child in doc.children {
            cache.set(MarkdownNodeView(Text("Test")), for: child, configuration: config)
        }

        #expect(cache.size == 3)

        // Generate some hits
        for child in doc.children {
            _ = cache.get(for: child, configuration: config)
        }

        #expect(cache.hits > 0 || cache.misses > 0)

        // Clear
        cache.clear()

        #expect(cache.size == 0)
        #expect(cache.hits == 0)
        #expect(cache.misses == 0)
        #expect(cache.hitRate == 0.0)

        // All should be misses now
        for child in doc.children {
            #expect(cache.get(for: child, configuration: config) == nil)
        }
    }

    // MARK: - Realistic Streaming Scenarios

    @Test("Streaming scenario - append only")
    func testStreamingAppendOnly() {
        let cache = NodeViewCache(maxSize: 100)
        let config = MarkdownRendererConfiguration()

        // Simulate streaming: Start with 2 paragraphs
        let chunk1 = "Para 1\n\nPara 2"
        let doc1 = Document(parsing: chunk1)

        // Cache initial render
        for child in doc1.children {
            cache.set(MarkdownNodeView(Text("Cached")), for: child, configuration: config)
        }

        let initialSize = cache.size
        #expect(initialSize == 2)

        // Add third paragraph
        let chunk2 = "Para 1\n\nPara 2\n\nPara 3"
        let doc2 = Document(parsing: chunk2)
        let children2 = Array(doc2.children)

        // First 2 should hit cache
        let hit1 = cache.get(for: children2[0], configuration: config)
        let hit2 = cache.get(for: children2[1], configuration: config)
        let miss3 = cache.get(for: children2[2], configuration: config)

        #expect(hit1 != nil)
        #expect(hit2 != nil)
        #expect(miss3 == nil)

        // Cache hit rate should be 66%
        #expect(cache.hitRate >= 0.6)
    }

    @Test("Streaming scenario - editing middle")
    func testStreamingEditMiddle() {
        let cache = NodeViewCache(maxSize: 100)
        let config = MarkdownRendererConfiguration()

        // Initial content
        let initial = "Para 1\n\nPara 2\n\nPara 3"
        let doc1 = Document(parsing: initial)

        // Cache all
        for child in doc1.children {
            cache.set(MarkdownNodeView(Text("Cached")), for: child, configuration: config)
        }

        // Modify middle paragraph
        let modified = "Para 1\n\nModified Para 2\n\nPara 3"
        let doc2 = Document(parsing: modified)
        let children2 = Array(doc2.children)

        // Para 1 and 3 should hit
        let hit1 = cache.get(for: children2[0], configuration: config)
        let miss2 = cache.get(for: children2[1], configuration: config)
        let hit3 = cache.get(for: children2[2], configuration: config)

        #expect(hit1 != nil)
        #expect(miss2 == nil) // Modified, so cache miss
        #expect(hit3 != nil)
    }

    // MARK: - Large Document Caching

    @Test("Large document caching")
    func testLargeDocument() {
        let cache = NodeViewCache(maxSize: 200)
        let config = MarkdownRendererConfiguration()

        // Create document with 100 paragraphs
        var paragraphs: [String] = []
        for i in 1...100 {
            paragraphs.append("Paragraph \(i)")
        }

        let markdown = paragraphs.joined(separator: "\n\n")
        let doc = Document(parsing: markdown)
        let children = Array(doc.children)

        #expect(children.count == 100)

        // Cache all
        for child in children {
            cache.set(MarkdownNodeView(Text("Cached")), for: child, configuration: config)
        }

        #expect(cache.size == 100)

        // All should hit
        var hits = 0
        for child in children {
            if cache.get(for: child, configuration: config) != nil {
                hits += 1
            }
        }

        #expect(hits == 100)
        #expect(cache.hitRate == 1.0) // 100% hit rate after caching
    }

    @Test("Large document with capacity limit")
    func testLargeDocumentWithLimit() {
        let cache = NodeViewCache(maxSize: 50) // Limited capacity
        let config = MarkdownRendererConfiguration()

        // Create document with 100 paragraphs
        var paragraphs: [String] = []
        for i in 1...100 {
            paragraphs.append("Paragraph \(i)")
        }

        let markdown = paragraphs.joined(separator: "\n\n")
        let doc = Document(parsing: markdown)
        let children = Array(doc.children)

        // Cache all (but only last 50 will be retained)
        for child in children {
            cache.set(MarkdownNodeView(Text("Cached")), for: child, configuration: config)
        }

        #expect(cache.size == 50) // Capped at max size

        // First 50 should be evicted
        for child in children.prefix(50) {
            #expect(cache.get(for: child, configuration: config) == nil)
        }

        // Last 50 should be cached
        for child in children.suffix(50) {
            #expect(cache.get(for: child, configuration: config) != nil)
        }
    }

    // MARK: - Cache Statistics

    @Test("Cache statistics are accurate")
    func testCacheStatistics() {
        let cache = NodeViewCache(maxSize: 10)
        let config = MarkdownRendererConfiguration()
        let doc = Document(parsing: "A\n\nB\n\nC")
        let children = Array(doc.children)

        // Initial state
        #expect(cache.hits == 0)
        #expect(cache.misses == 0)
        #expect(cache.size == 0)

        // 3 misses
        for child in children {
            _ = cache.get(for: child, configuration: config)
        }

        #expect(cache.hits == 0)
        #expect(cache.misses == 3)

        // Cache them
        for child in children {
            cache.set(MarkdownNodeView(Text("Test")), for: child, configuration: config)
        }

        #expect(cache.size == 3)

        // 3 hits
        for child in children {
            _ = cache.get(for: child, configuration: config)
        }

        #expect(cache.hits == 3)
        #expect(cache.misses == 3)
        #expect(cache.hitRate == 0.5)
    }

    // MARK: - Edge Cases

    @Test("Empty cache has zero hit rate")
    func testEmptyCacheHitRate() {
        let cache = NodeViewCache(maxSize: 10)

        #expect(cache.hitRate == 0.0)
        #expect(cache.size == 0)
    }

    @Test("Single entry cache")
    func testSingleEntryCache() {
        let cache = NodeViewCache(maxSize: 1)
        let config = MarkdownRendererConfiguration()
        let doc = Document(parsing: "A\n\nB")
        let children = Array(doc.children)

        // Cache first
        cache.set(MarkdownNodeView(Text("A")), for: children[0], configuration: config)
        #expect(cache.size == 1)

        // Cache second (evicts first)
        cache.set(MarkdownNodeView(Text("B")), for: children[1], configuration: config)
        #expect(cache.size == 1)

        // First should be evicted
        #expect(cache.get(for: children[0], configuration: config) == nil)

        // Second should be cached
        #expect(cache.get(for: children[1], configuration: config) != nil)
    }

    @Test("Very large cache size")
    func testVeryLargeCacheSize() {
        let cache = NodeViewCache(maxSize: 10000)
        let config = MarkdownRendererConfiguration()

        // Should handle large capacity without issues
        for i in 1...100 {
            let doc = Document(parsing: "Paragraph \(i)")
            if let child = Array(doc.children).first {
                cache.set(MarkdownNodeView(Text("Test")), for: child, configuration: config)
            }
        }

        #expect(cache.size == 100)
        #expect(cache.size < 10000)
    }
}
