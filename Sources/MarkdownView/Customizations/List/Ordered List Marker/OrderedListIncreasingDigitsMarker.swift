//
//  OrderedListIncreasingDigitsMarker.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

/// An auto-increasing digits marker for ordered list items.
public struct OrderedListIncreasingDigitsMarker: OrderedListMarkerProtocol {
    public func marker(at index: Int, listDepth: Int) -> String {
        String(index + 1) + "."
    }
    
    public var monospaced: Bool { false }
}

extension OrderedListMarkerProtocol where Self == OrderedListIncreasingDigitsMarker {
    /// An auto-increasing digits marker for ordered list items.
    static public var increasingDigits: OrderedListIncreasingDigitsMarker { .init() }
}
