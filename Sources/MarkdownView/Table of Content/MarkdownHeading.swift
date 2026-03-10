//
//  MarkdownHeading.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/28.
//

import Foundation
import Markdown

/// A representation of a markdown heading.
public struct MarkdownHeading: Hashable, Sendable {
    private var heading: Markdown.Heading
    
    /// Heading level, starting from 1.
    public var level: Int {
        heading.level
    }
    /// The range of the heading in the raw Markdown.
    ///
    /// The range originates from `swift-markdown`’s parsing result. It is
    /// present when the Markdown source carried location information (for
    /// example when it was loaded from a file URL).
    public var range: SourceRange? {
        heading.range
    }
    /// The content text of the heading.
    public var plainText: String {
        heading.plainText
    }
    
    init(heading: Heading) {
        self.heading = heading
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(level)
        hasher.combine(range)
        hasher.combine(plainText)
    }
    
    public static func == (lhs: MarkdownHeading, rhs: MarkdownHeading) -> Bool {
        lhs.heading.isIdentical(to: rhs.heading)
    }
}
