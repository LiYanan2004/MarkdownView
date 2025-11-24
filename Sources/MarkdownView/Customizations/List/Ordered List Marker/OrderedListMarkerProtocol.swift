//
//  OrderedListMarkerProtocol.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

/// A type that represents the marker for ordered list items.
public protocol OrderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific index of ordered list item. Index starting from 0.
    func marker(at index: Int, listDepth: Int) -> String
    
    /// A boolean value indicates whether the marker should be monospaced, default value is `true`.
    var monospaced: Bool { get }
}

extension OrderedListMarkerProtocol {
    public var monospaced: Bool {
        true
    }
}
