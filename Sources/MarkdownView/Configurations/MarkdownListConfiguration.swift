//
//  MarkdownListConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Markdown
import Foundation

struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
    var leadingIndentation: CGFloat = 12
    var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
    var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
}

// MARK: - Ordered List Marker

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

struct AnyOrderedListMarkerProtocol: OrderedListMarkerProtocol {
    private var _marker: AnyHashable
    var monospaced: Bool {
        (_marker as! (any OrderedListMarkerProtocol)).monospaced
    }
    
    init<T: OrderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(at index: Int, listDepth: Int) -> String {
        (_marker as! (any OrderedListMarkerProtocol)).marker(at: index, listDepth: listDepth)
    }
}

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

/// An auto-increasing letters marker for ordered list items.
public struct OrderedListIncreasingLettersMarker: OrderedListMarkerProtocol {
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

extension OrderedListMarkerProtocol where Self == OrderedListIncreasingLettersMarker {
    /// An auto-increasing letters marker for ordered list items.
    static public var increasingLetters: OrderedListIncreasingLettersMarker { .init() }
}

// MARK: - Unordered List Marker

/// A type that represents the marker for unordered list items.
public protocol UnorderedListMarkerProtocol: Hashable {
    /// Returns a marker for a specific indentation level of unordered list item. indentationLevel starting from 0.
    func marker(listDepth: Int) -> String
    
    /// A boolean value indicates whether the marker should be monospaced, default value is `true`.
    var monospaced: Bool { get }
}

extension UnorderedListMarkerProtocol {
    public var monospaced: Bool {
        true
    }
}

struct AnyUnorderedListMarkerProtocol: UnorderedListMarkerProtocol {
    private var _marker: AnyHashable
    var monospaced: Bool {
        (_marker as! (any UnorderedListMarkerProtocol)).monospaced
    }
    
    init<T: UnorderedListMarkerProtocol>(_ marker: T) {
        self._marker = AnyHashable(marker)
    }
    
    public func marker(listDepth: Int) -> String {
        (_marker as! (any UnorderedListMarkerProtocol)).marker(listDepth: listDepth)
    }
}

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
