//
//  MarkdownTableRowStyleCollection.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

@dynamicMemberLookup
struct MarkdownTableRowStyleCollection: Sendable {
    typealias Storage = [MarkdownTableRowStyle.Position : MarkdownTableRowStyle]
    fileprivate var storage: Storage = [:] {
        willSet { cacheBox.reset() }
    }
    
    private class CacheBox: /* NSLock */ @unchecked Sendable {
        enum CacheKey: Hashable {
            case minYs
            case maxYs
            case heights
            case rows
            case offsets(MarkdownTableRowStyle.Position)
        }
        
        private var caches: [CacheKey : Any] = [:]
        private let lock = NSLock()
        
        subscript(key: CacheKey) -> Any? {
            lock.lock()
            defer { lock.unlock() }
            return caches[key]
        }
        
        func updateValue(_ value: Any, forKey key: CacheKey) {
            lock.lock()
            caches[key] = value
            lock.unlock()
        }
        
        func reset() {
            lock.lock()
            caches.removeAll(keepingCapacity: true)
            lock.unlock()
        }
    }
    private var cacheBox = CacheBox()
    
    subscript<T>(dynamicMember keyPath: KeyPath<Storage, T>) -> T {
        storage[keyPath: keyPath]
    }
    
    subscript(storageKey: MarkdownTableRowStyle.Position) -> MarkdownTableRowStyle? {
        get { storage[storageKey] }
        set { storage[storageKey] = newValue }
    }
    
    var rows: [MarkdownTableRowStyle] {
        if let cached = cacheBox[.rows] {
            return cached as! [MarkdownTableRowStyle]
        }
        
        let rows = Array(storage.values)
        cacheBox.updateValue(rows, forKey: .rows)
        return rows
    }
    
    var minYs: [CGFloat] {
        if let cached = cacheBox[.minYs] {
            return cached as! [CGFloat]
        }
        
        let rowCount = Set(rows.map(\.position.row)).count
        let minYs = (0..<rowCount).map { row in
            rows.filter { $0.position.row == row }.map(\.minY).min() ?? 0
        }
        cacheBox.updateValue(minYs, forKey: .minYs)
        return minYs
    }
    
    var maxYs: [CGFloat] {
        if let cached = cacheBox[.maxYs] {
            return cached as! [CGFloat]
        }
        
        let rowCount = Set(rows.map(\.position.row)).count
        let maxYs = (0..<rowCount).map { row in
            rows.filter { $0.position.row == row }.map(\.maxY).max() ?? 0
        }
        cacheBox.updateValue(maxYs, forKey: .maxYs)
        return maxYs
    }
    
    var heights: [CGFloat] {
        if let cached = cacheBox[.heights] {
            return cached as! [CGFloat]
        }
        
        let normalHeights = zip(maxYs, minYs).map(-)
        
        var heights = normalHeights
        let additionalHeights = zip(minYs.dropFirst(), maxYs.dropLast()).map(-)
        
        for (index, additionalHeight) in additionalHeights.enumerated() {
            heights[index] += additionalHeight
        }
        cacheBox.updateValue(heights, forKey: .heights)
        return heights
    }
    
    func offset(for position: MarkdownTableRowStyle.Position) -> CGSize {
        guard storage[position] != nil else { return .zero }
        
        if let cached = cacheBox[.offsets(position)] {
            return cached as! CGSize
        }
        
        let offset = CGSize(
            width: 0,
            height: minYs[position.row]
        )
        cacheBox.updateValue(offset, forKey: .offsets(position))
        return offset
    }
}

// MARK: - Preference Key

struct MarkdownTableRowStyleCollectionPreference: PreferenceKey {
    static let defaultValue: MarkdownTableRowStyleCollection = MarkdownTableRowStyleCollection()
    
    static func reduce(
        value: inout MarkdownTableRowStyleCollection,
        nextValue: () -> MarkdownTableRowStyleCollection
    ) {
        value.storage.merge(nextValue().storage, uniquingKeysWith: { $1 })
    }
}
