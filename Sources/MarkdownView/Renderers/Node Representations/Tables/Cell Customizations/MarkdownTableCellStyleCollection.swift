//
//  MarkdownTableCellStyleCollection.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

@dynamicMemberLookup
struct MarkdownTableCellStyleCollection {
    typealias Storage = [MarkdownTableCellStyle.Position : MarkdownTableCellStyle]
    fileprivate var storage: Storage = [:] {
        willSet { cacheBox.caches = [:] }
    }
    
    private class CacheBox {
        enum CacheKey: Hashable {
            case minXs
            case maxXs
            case minYs
            case maxYs
            case widths
            case heights
            case cells
            case offsets(MarkdownTableCellStyle.Position)
        }
        var caches: [CacheKey : Any] = [:]
    }
    private var cacheBox = CacheBox()
    
    subscript<T>(dynamicMember keyPath: KeyPath<Storage, T>) -> T {
        storage[keyPath: keyPath]
    }
    
    subscript(storageKey: MarkdownTableCellStyle.Position) -> MarkdownTableCellStyle? {
        get { storage[storageKey] }
        set { storage[storageKey] = newValue }
    }
    
    var cells: [MarkdownTableCellStyle] {
        if let cached = cacheBox.caches[.cells] {
            return cached as! [MarkdownTableCellStyle]
        }
        
        let cells = Array(storage.values)
        cacheBox.caches[.cells] = cells
        return cells
    }
    
    var minXs: [CGFloat] {
        if let cached = cacheBox.caches[.minXs] {
            return cached as! [CGFloat]
        }
        
        let columns = Set(cells.map(\.position.column)).count
        let minXs = (0..<columns).map { column in
            cells.filter { $0.position.column == column }.map(\.rect.minX).min() ?? 0
        }
        cacheBox.caches[.minXs] = minXs
        return minXs
    }
    
    var maxXs: [CGFloat] {
        if let cached = cacheBox.caches[.maxXs] {
            return cached as! [CGFloat]
        }
        
        let columns = Set(cells.map(\.position.column)).count
        let maxXs = (0..<columns).map { column in
            cells.filter { $0.position.column == column }.map(\.rect.maxX).max() ?? 0
        }
        cacheBox.caches[.maxXs] = maxXs
        return maxXs
    }
    
    var minYs: [CGFloat] {
        if let cached = cacheBox.caches[.minYs] {
            return cached as! [CGFloat]
        }
        
        let rows = Set(cells.map(\.position.row)).count
        let minYs = (0..<rows).map { row in
            cells.filter { $0.position.row == row }.map(\.rect.minY).min() ?? 0
        }
        cacheBox.caches[.minYs] = minYs
        return minYs
    }
    
    var maxYs: [CGFloat] {
        if let cached = cacheBox.caches[.maxYs] {
            return cached as! [CGFloat]
        }
        
        let rows = Set(cells.map(\.position.row)).count
        let maxYs = (0..<rows).map { row in
            cells.filter { $0.position.row == row }.map(\.rect.maxY).max() ?? 0
        }
        cacheBox.caches[.maxYs] = maxYs
        return maxYs
    }
    
    var widths: [CGFloat] {
        if let cached = cacheBox.caches[.widths] {
            return cached as! [CGFloat]
        }
        
        let normalWidths = zip(maxXs, minXs).map(-)
        
        var widths = normalWidths
        let additionalWidths = zip(minXs.dropFirst(), maxXs.dropLast()).map(-)
        
        for (index, additionalWidth) in additionalWidths.enumerated() {
            widths[index] += additionalWidth
        }
        cacheBox.caches[.widths] = widths
        return widths
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
    
    func offset(for position: MarkdownTableCellStyle.Position) -> CGSize {
        guard storage[position] != nil else { return .zero }
        
        if let cached = cacheBox.caches[.offsets(position)] {
            return cached as! CGSize
        }
        
        let offset = CGSize(
            width: minXs[position.column],
            height: minYs[position.row]
        )
        cacheBox.caches[.offsets(position)] = offset
        return offset
    }
}

// MARK: - Preference Key

@MainActor
struct MarkdownTableCellStyleCollectionPreference: @preconcurrency PreferenceKey {
    static var defaultValue: MarkdownTableCellStyleCollection = MarkdownTableCellStyleCollection()
    
    static func reduce(value: inout MarkdownTableCellStyleCollection, nextValue: () -> MarkdownTableCellStyleCollection) {
        value.storage.merge(nextValue().storage, uniquingKeysWith: { $1 })
    }
}
