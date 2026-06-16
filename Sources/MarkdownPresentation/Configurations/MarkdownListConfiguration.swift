//
//  MarkdownListConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Markdown
import Foundation

package struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
    package var leadingIndentation: CGFloat = 12
    package var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
    package var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
}

// MARK: - Ordered List Marker

/// A type that represents the marker for ordered list items.
public protocol MarkdownOrderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific index of ordered list item. Index starting from 0.
    func marker(at index: Int, listDepth: Int) -> String
    
    /// A boolean value indicates whether the marker should be monospaced, default value is `true`.
    var monospaced: Bool { get }
}

extension MarkdownOrderedListMarkerProtocol {
    public var monospaced: Bool {
        true
    }
}

package struct AnyOrderedListMarkerProtocol: MarkdownOrderedListMarkerProtocol {
    private var _marker: AnyHashable
    package var monospaced: Bool {
        (_marker as! (any MarkdownOrderedListMarkerProtocol)).monospaced
    }
    
    package init<T: MarkdownOrderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(at index: Int, listDepth: Int) -> String {
        (_marker as! (any MarkdownOrderedListMarkerProtocol)).marker(at: index, listDepth: listDepth)
    }
}

/// An auto-increasing digits marker for ordered list items.
public struct OrderedListIncreasingDigitsMarker: MarkdownOrderedListMarkerProtocol {
    public func marker(at index: Int, listDepth: Int) -> String {
        String(index + 1) + "."
    }
    
    public var monospaced: Bool { false }
}

extension MarkdownOrderedListMarkerProtocol where Self == OrderedListIncreasingDigitsMarker {
    /// An auto-increasing digits marker for ordered list items.
    static public var increasingDigits: OrderedListIncreasingDigitsMarker { .init() }
}

/// An auto-increasing letters marker for ordered list items.
public struct OrderedListIncreasingLettersMarker: MarkdownOrderedListMarkerProtocol {
    public func marker(at index: Int, listDepth: Int) -> String {
        let base = 26
        var index = index
        var result = ""
        
        // If index is smaller than 26, use single letter, otherwise, use double letters.
        if index < base {
            result = String(UnicodeScalar("a".unicodeScalars.first!.value + UInt32(index))!)
        } else {
            index -= base
            let firstLetterIndex = index / base
            let secondLetterIndex = index % base
            let firstLetter = UnicodeScalar("a".unicodeScalars.first!.value + UInt32(firstLetterIndex))!
            let secondLetter = UnicodeScalar("a".unicodeScalars.first!.value + UInt32(secondLetterIndex))!
            result.append(Character(firstLetter))
            result.append(Character(secondLetter))
        }
        
        return result + "."
    }
    
    public var monospaced: Bool { false }
}

extension MarkdownOrderedListMarkerProtocol where Self == OrderedListIncreasingLettersMarker {
    /// An auto-increasing letters marker for ordered list items.
    static public var increasingLetters: OrderedListIncreasingLettersMarker { .init() }
}

// MARK: - Unordered List Marker

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

package struct AnyUnorderedListMarkerProtocol: MarkdownUnorderedListMarkerProtocol {
    private var _marker: AnyHashable
    package var monospaced: Bool {
        (_marker as! (any MarkdownUnorderedListMarkerProtocol)).monospaced
    }
    
    package init<T: MarkdownUnorderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(listDepth: Int) -> String {
        (_marker as! (any MarkdownUnorderedListMarkerProtocol)).marker(listDepth: listDepth)
    }
}

/// A dash marker for unordered list items.
public struct UnorderedListDashMarker: MarkdownUnorderedListMarkerProtocol {
    public func marker(listDepth: Int) -> String {
        "-"
    }
}

extension MarkdownUnorderedListMarkerProtocol where Self == UnorderedListDashMarker {
    /// A dash marker for unordered list items.
    static public var dash: UnorderedListDashMarker { .init() }
}

/// A bullet marker for unordered list items.
public struct UnorderedListBulletMarker: MarkdownUnorderedListMarkerProtocol {
    public func marker(listDepth: Int) -> String {
        "•"
    }
}

extension MarkdownUnorderedListMarkerProtocol where Self == UnorderedListBulletMarker {
    /// A bullet marker for unordered list items.
    static public var bullet: UnorderedListBulletMarker { .init() }
}

// MARK: - Deprecations

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownOrderedListMarkerProtocol")
public typealias OrderedListMarkerProtocol = MarkdownOrderedListMarkerProtocol

@_documentation(visibility: internal)
@available(*, deprecated, renamed: "MarkdownUnorderedListMarkerProtocol")
public typealias UnorderedListMarkerProtocol = MarkdownUnorderedListMarkerProtocol
