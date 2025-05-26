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
        willSet { cacheBox.caches = [:] }
    }
    
    private class CacheBox: @unchecked Sendable {
        enum CacheKey: Hashable {
            case minYs
            case maxYs
            case heights
            case rows
            case offsets(MarkdownTableRowStyle.Position)
        }
        private var lock = NSLock()
        private var _caches: [CacheKey : Any] = [:]
        
        var caches: [CacheKey : Any] {
            get {
                lock.withLock {
                    return _caches
                }
            }
            set {
                lock.withLock {
                    _caches = newValue
                }
            }
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
        if let cached = cacheBox.caches[.rows] {
            return cached as! [MarkdownTableRowStyle]
        }
        
        let cells = Array(storage.values)
        cacheBox.caches[.rows] = cells
        return cells
    }
    
    var minYs: [CGFloat] {
        if let cached = cacheBox.caches[.minYs] {
            return cached as! [CGFloat]
        }
        
        let rowCount = Set(rows.map(\.position.row)).count
        let minYs = (0..<rowCount).map { row in
            rows.filter { $0.position.row == row }.map(\.minY).min() ?? 0
        }
        cacheBox.caches[.minYs] = minYs
        return minYs
    }
    
    var maxYs: [CGFloat] {
        if let cached = cacheBox.caches[.maxYs] {
            return cached as! [CGFloat]
        }
        
        let rowCount = Set(rows.map(\.position.row)).count
        let maxYs = (0..<rowCount).map { row in
            rows.filter { $0.position.row == row }.map(\.maxY).max() ?? 0
        }
        cacheBox.caches[.maxYs] = maxYs
        return maxYs
    }
    
    var heights: [CGFloat] {
        if let cached = cacheBox.caches[.heights] {
            return cached as! [CGFloat]
        }
        
        let normalHeights = zip(maxYs, minYs).map(-)
        
        var heights = normalHeights
        let additionalHeights = zip(minYs.dropFirst(), maxYs.dropLast()).map(-)
        
        for (index, additionalHeight) in additionalHeights.enumerated() {
            heights[index] += additionalHeight
        }
        cacheBox.caches[.heights] = heights
        return heights
    }
    
    func offset(for position: MarkdownTableRowStyle.Position) -> CGSize {
        guard storage[position] != nil else { return .zero }
        
        if let cached = cacheBox.caches[.offsets(position)] {
            return cached as! CGSize
        }
        
        let offset = CGSize(
            width: 0,
            height: minYs[position.row]
        )
        cacheBox.caches[.offsets(position)] = offset
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
