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
    
    var widths: [CGFloat] {
        if let cached = cacheBox.caches[.widths] {
            return cached as! [CGFloat]
        }
        
        let columns = Set(cells.map(\.position.column)).count
        let widths = (0..<columns).map { column in
            cells.filter { $0.position.column == column }.map(\.width).max() ?? 0
        }
        cacheBox.caches[.widths] = widths
        return widths
    }
    
    var heights: [CGFloat] {
        if let cached = cacheBox.caches[.heights] {
            return cached as! [CGFloat]
        }
        
        let rows = Set(cells.map(\.position.row)).count
        let heights = (0..<rows).map { row in
            cells.filter { $0.position.row == row }.map(\.height).max() ?? 0
        }
        cacheBox.caches[.heights] = heights
        return heights
    }
    
    func offset(for position: MarkdownTableCellStyle.Position) -> CGSize {
        if let cached = cacheBox.caches[.offsets(position)] {
            return cached as! CGSize
        }
        
        let offset = CGSize(
            width: widths[0..<max(0, position.column)].reduce(0, +),
            height: heights[0..<max(0, position.row)].reduce(0, +)
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
