//
//  UnorderedListMarkerProtocol.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/27.
//

import Foundation

/// A type that represents the marker for unordered list items.
public protocol MarkdownUnorderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific indentation level of unordered list item. indentationLevel starting from 0.
    func marker(listDepth: Int) -> String
    
    /// A boolean value indicates whether the marker should be monospaced, default value is `true`.
    var monospaced: Bool { get }
}

extension MarkdownUnorderedListMarkerProtocol {
    public var monospaced: Bool {
        true
    }
}

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownUnorderedListMarkerProtocol")
public typealias UnorderedListMarkerProtocol = MarkdownUnorderedListMarkerProtocol
