//
//  HeadingVerticalPaddingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/22.
//

import SwiftUI

extension View {
    /// Sets vertical paddings for specific heading.
    ///
    /// Default amount of paddings are added to top edge, values are:
    /// - h1: 24
    /// - h2: 24
    /// - h3: 16
    /// - h4: 10
    /// - h5: 10
    /// - h6: 10
    ///
    /// - parameter edges: The set of edges to pad for headings. The default is `Edge.Set.top`.
    /// - parameter length: The length of the vertical padding on each side.
    /// - parameter headingLevel: The level of the heading to use the specified padding length.
    nonisolated public func padding(
        _ edges: Edge.Set = .top,
        _ length: CGFloat,
        for headingLevel: HeadingLevel
    ) -> some View {
        transformEnvironment(\.headingPaddings) { paddings in
            if edges.contains(.top) {
                paddings[headingLevel.rawValue, .top] = length
            }
            if edges.contains(.leading) {
                paddings[headingLevel.rawValue, .leading] = length
            }
            if edges.contains(.bottom) {
                paddings[headingLevel.rawValue, .bottom] = length
            }
            if edges.contains(.trailing) {
                paddings[headingLevel.rawValue, .trailing] = length
            }
        }
    }
    
    /// Sets vertical paddings for specific heading.
    ///
    /// Default amount of paddings are added to top edge, values are:
    /// - h1: 24
    /// - h2: 24
    /// - h3: 16
    /// - h4: 10
    /// - h5: 10
    /// - h6: 10
    ///
    /// - parameter length: The length of the vertical padding on each side.
    /// - parameter headingLevel: The level of the heading to use the specified padding length.
    nonisolated public func padding(
        _ length: CGFloat,
        for headingLevel: HeadingLevel
    ) -> some View {
        transformEnvironment(\.headingPaddings) { paddings in
            paddings[headingLevel.rawValue, .top] = length
        }
    }
    
    @_disfavoredOverload
    nonisolated public func padding(
        _ insets: EdgeInsets,
        for headingLevel: HeadingLevel
    ) -> some View {
        transformEnvironment(\.headingPaddings) { paddings in
            paddings[headingLevel.rawValue] = insets
        }
    }
    
    nonisolated public func _zeroPaddingForAllHeadings() -> some View {
        transformEnvironment(\.headingPaddings) { paddings in
            for level in 1...6 {
                paddings[level] = EdgeInsets()
            }
        }
    }
}
