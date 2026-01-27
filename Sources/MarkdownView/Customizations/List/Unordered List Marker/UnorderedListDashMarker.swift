//
//  UnorderedListDashMarker.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

/// A dash marker for unordered list items.
public struct UnorderedListDashMarker: UnorderedListMarkerProtocol {
    public func marker(listDepth: Int) -> String {
        "-"
    }
}

extension UnorderedListMarkerProtocol where Self == UnorderedListDashMarker {
    /// A dash marker for unordered list items.
    static public var dash: UnorderedListDashMarker { .init() }
}
