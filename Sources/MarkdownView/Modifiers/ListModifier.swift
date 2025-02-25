//
//  ListModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    nonisolated public func markdownListIndent(_ indent: CGFloat) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.listConfiguration.leadingIndentation = indent
        }
    }
    
    @available(*, deprecated, renamed: "markdownUnorderedListMarker", message: "Use `markdownUnorderedListMarker` instead.")
    @_documentation(visibility: internal)
    nonisolated public func markdownUnorderedListBullet(_ bullet: String) -> some View {
        self
    }
    
    nonisolated public func markdownUnorderedListMarker(_ marker: some UnorderedListMarkerProtocol) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.listConfiguration.unorderedListMarker = AnyUnorderedListMarkerProtocol(marker)
        }
    }
    
    nonisolated public func markdownOrderedListMarker(_ marker: some OrderedListMarkerProtocol) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.listConfiguration.orderedListMarker = AnyOrderedListMarkerProtocol(marker)
        }
    }
    
    nonisolated public func markdownComponentSpacing(_ spacing: CGFloat) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.componentSpacing = spacing
        }
    }
}
