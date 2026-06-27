//
//  ListModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Sets the indentation applied to each nested markdown list level.
    ///
    /// - Parameter indent: The indentation, in points, for each nested level.
    nonisolated public func markdownListIndent(_ indent: CGFloat) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.listConfiguration.leadingIndentation = indent
        }
    }
    
    /// Sets the marker used for unordered markdown list items.
    ///
    /// - Parameter marker: The marker style to use for unordered list items.
    nonisolated public func markdownUnorderedListMarker(_ marker: some MarkdownUnorderedListMarkerProtocol) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.listConfiguration.unorderedListMarker = AnyUnorderedListMarkerProtocol(marker)
        }
    }
    
    /// Sets the marker used for ordered markdown list items.
    ///
    /// - Parameter marker: The marker style to use for ordered list items.
    nonisolated public func markdownOrderedListMarker(_ marker: some MarkdownOrderedListMarkerProtocol) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.listConfiguration.orderedListMarker = AnyOrderedListMarkerProtocol(marker)
        }
    }
    
    /// Sets the spacing between top-level rendered markdown components.
    ///
    /// - Parameter spacing: The spacing, in points, between adjacent components.
    nonisolated public func markdownComponentSpacing(_ spacing: CGFloat) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.componentSpacing = spacing
        }
    }
}
