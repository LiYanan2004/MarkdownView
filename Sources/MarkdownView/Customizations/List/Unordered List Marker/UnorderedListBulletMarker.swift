//
//  UnorderedListBulletMarker.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

/// A bullet marker for unordered list items.
public struct UnorderedListBulletMarker: UnorderedListMarkerProtocol {
    public func marker(listDepth: Int) -> String {
        "•"
    }
}

extension UnorderedListMarkerProtocol where Self == UnorderedListBulletMarker {
    /// A bullet marker for unordered list items.
    static public var bullet: UnorderedListBulletMarker { .init() }
}
