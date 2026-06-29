//
//  HeadingVerticalPaddingModifier.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/22.
//

import SwiftUI

extension View {
    /// Sets vertical paddings for one or more headings.
    ///
    /// Default amount of paddings are added to top edge, values are:
    /// - h1: 24
    /// - h2: 24
    /// - h3: 16
    /// - h4: 10
    /// - h5: 10
    /// - h6: 10
    ///
    /// This modifier does not affect `MarkdownText`.
    ///
    /// - parameter edges: The set of edges to pad for headings. The default is `Edge.Set.top`.
    /// - parameter length: The length of the vertical padding on each side.
    /// - parameter headingLevels: The heading levels to use the specified padding length.
    @_disfavoredOverload
    nonisolated public func padding(
        _ edges: Edge.Set = .top,
        _ length: CGFloat,
        for headingLevels: HeadingLevel...
    ) -> some View {
        transformEnvironment(\.headingPaddings) { paddings in
            for headingLevel in headingLevels {
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
    }
    
    /// Sets vertical paddings for one or more headings.
    ///
    /// This modifier does not affect `MarkdownText`.
    @_disfavoredOverload
    nonisolated public func padding(
        _ insets: EdgeInsets,
        for headingLevels: HeadingLevel...
    ) -> some View {
        transformEnvironment(\.headingPaddings) { paddings in
            for headingLevel in headingLevels {
                paddings[headingLevel.rawValue] = insets
            }
        }
    }
    
    @available(*, deprecated, message: "Use `.padding(EdgeInsets(), for: .h1, .h2, .h3, .h4, .h5, .h6)` instead.")
    nonisolated public func _zeroPaddingForAllHeadings() -> some View {
        padding(EdgeInsets(), for: .h1, .h2, .h3, .h4, .h5, .h6)
    }
}
