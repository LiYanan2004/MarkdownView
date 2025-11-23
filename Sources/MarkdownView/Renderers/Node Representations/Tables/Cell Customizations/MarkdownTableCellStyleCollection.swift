//
//  MarkdownTableCellStyleCollection.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/18.
//

import SwiftUI

@dynamicMemberLookup
struct MarkdownTableCellStyleCollection: Sendable {
    typealias Storage = [MarkdownTableCellStyle.Position : MarkdownTableCellStyle]
    fileprivate var storage: Storage = [:] {
        willSet { cacheBox.reset() }
    }
    
    private class CacheBox: /* via DispatchQueue */ @unchecked Sendable {
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
        private var caches: [CacheKey : Any] = [:]
        private var queue = DispatchQueue(
            label: "com.liyanan2004.MarkdownView.TableCellStyle"
        )
        
        subscript(key: CacheKey) -> Any? {
            queue.sync { caches[key] }
        }
        
        func updateValue(_ value: Any, forKey key: CacheKey) {
            queue.sync {
                caches[key] = value
            }
        }
        
        func reset() {
            queue.sync {
                caches = [:]
            }
        }
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
        if let cached = cacheBox[.cells] {
            return cached as! [MarkdownTableCellStyle]
        }
        
        let cells = Array(storage.values)
        cacheBox.updateValue(cells, forKey: .cells)
        return cells
    }
    
    var minXs: [CGFloat] {
        if let cached = cacheBox[.minXs] {
            return cached as! [CGFloat]
        }
        
        let columns = Set(cells.map(\.position.column)).count
        let minXs = (0..<columns).map { column in
            cells.filter { $0.position.column == column }.map(\.rect.minX).min() ?? 0
        }
        cacheBox.updateValue(minXs, forKey: .minXs)
        return minXs
    }
    
    var maxXs: [CGFloat] {
        if let cached = cacheBox[.maxXs] {
            return cached as! [CGFloat]
        }
        
        let columns = Set(cells.map(\.position.column)).count
        let maxXs = (0..<columns).map { column in
            cells.filter { $0.position.column == column }.map(\.rect.maxX).max() ?? 0
        }
        cacheBox.updateValue(maxXs, forKey: .maxXs)
        return maxXs
    }
    
    var minYs: [CGFloat] {
        if let cached = cacheBox[.minYs] {
            return cached as! [CGFloat]
        }
        
        let rows = Set(cells.map(\.position.row)).count
        let minYs = (0..<rows).map { row in
            cells.filter { $0.position.row == row }.map(\.rect.minY).min() ?? 0
        }
        cacheBox.updateValue(minYs, forKey: .minYs)
        return minYs
    }
    
    var maxYs: [CGFloat] {
        if let cached = cacheBox[.maxYs] {
            return cached as! [CGFloat]
        }
        
        let rows = Set(cells.map(\.position.row)).count
        let maxYs = (0..<rows).map { row in
            cells.filter { $0.position.row == row }.map(\.rect.maxY).max() ?? 0
        }
        cacheBox.updateValue(maxYs, forKey: .maxYs)
        return maxYs
    }
    
    var widths: [CGFloat] {
        if let cached = cacheBox[.widths] {
            return cached as! [CGFloat]
        }
        
        let normalWidths = zip(maxXs, minXs).map(-)
        
        var widths = normalWidths
        let additionalWidths = zip(minXs.dropFirst(), maxXs.dropLast()).map(-)
        
        for (index, additionalWidth) in additionalWidths.enumerated() {
            widths[index] += additionalWidth
        }
        cacheBox.updateValue(widths, forKey: .widths)
        return widths
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
    
    func offset(for position: MarkdownTableCellStyle.Position) -> CGSize {
        guard storage[position] != nil else { return .zero }
        
        if let cached = cacheBox[.offsets(position)] {
            return cached as! CGSize
        }
        
        let offset = CGSize(
            width: minXs[position.column],
            height: minYs[position.row]
        )
        cacheBox.updateValue(offset, forKey: .offsets(position))
        return offset
    }
}

// MARK: - Preference Key

struct MarkdownTableCellStyleCollectionPreference: PreferenceKey {
    static let defaultValue: MarkdownTableCellStyleCollection = MarkdownTableCellStyleCollection()
    
    static func reduce(value: inout MarkdownTableCellStyleCollection, nextValue: () -> MarkdownTableCellStyleCollection) {
        value.storage.merge(nextValue().storage, uniquingKeysWith: { $1 })
    }
}

