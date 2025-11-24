//
//  ListModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Adjusts the leading indentation applied to list markers.
    ///
    /// The value applies to both ordered and unordered lists rendered by
    /// `MarkdownView`.
    ///
    /// - Parameter indent: The padding, in points, to apply in front of list content.
    nonisolated public func markdownListIndent(_ indent: CGFloat) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.list.leadingIndentation = indent
        }
    }
    
    /// Replaces the marker that unordered lists use for each item.
    ///
    /// Provide a type that conforms to ``UnorderedListMarkerProtocol`` to drive
    /// the bullet’s appearance.
    nonisolated public func markdownUnorderedListMarker(
        _ marker: some UnorderedListMarkerProtocol
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.list.unorderedListMarker = AnyUnorderedListMarkerProtocol(marker)
        }
    }
    
    /// Replaces the marker that ordered lists use for each row.
    ///
    /// Provide a type that conforms to ``OrderedListMarkerProtocol`` to control
    /// numbering, prefixes, and suffixes.
    nonisolated public func markdownOrderedListMarker(
        _ marker: some OrderedListMarkerProtocol
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.list.orderedListMarker = AnyOrderedListMarkerProtocol(marker)
        }
    }
    
    /// Sets the vertical spacing between block-level Markdown components such as
    /// paragraphs, list items, and block quotes.
    ///
    /// - Parameter spacing: The spacing value passed to `VStack` containers inside MarkdownView.
    nonisolated public func markdownComponentSpacing(_ spacing: CGFloat) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.componentSpacing = spacing
        }
    }
}
