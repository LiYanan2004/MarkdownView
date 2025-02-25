//
//  DeprecatedSymbols.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/2/26.
//

import SwiftUI

extension MarkdownView {
    @available(iOS, unavailable, renamed: "MarkdownView(_:)", message: "Use `MarkdownView(_:)`")
    @available(macOS, unavailable, renamed: "MarkdownView(_:)", message: "Use `MarkdownView(_:)`")
    @available(tvOS, unavailable, renamed: "MarkdownView(_:)", message: "Use `MarkdownView(_:)`")
    @available(watchOS, unavailable, renamed: "MarkdownView(_:)", message: "Use `MarkdownView(_:)`")
    @available(visionOS, unavailable, renamed: "MarkdownView(_:)", message: "Use `MarkdownView(_:)`")
    init(text: String) {
        fatalError()
    }
}

extension View {
    @available(iOS, unavailable, renamed: "markdownViewStyle", message: "Use markdownViewStyle instead.")
    @available(macOS, unavailable, renamed: "markdownViewStyle", message: "Use markdownViewStyle instead.")
    @available(tvOS, unavailable, renamed: "markdownViewStyle", message: "Use markdownViewStyle instead.")
    @available(watchOS, unavailable, renamed: "markdownViewStyle", message: "Use markdownViewStyle instead.")
    @available(visionOS, unavailable, renamed: "markdownViewStyle", message: "Use markdownViewStyle instead.")
    @_documentation(visibility: internal)
    nonisolated public func markdownViewRole(
        _ role: MarkdownView.Role
    ) -> some View {
        self
    }
}

extension View {
    @available(iOS, unavailable, renamed: "markdownUnorderedListMarker", message: "Use markdownUnorderedListMarker instead.")
    @available(macOS, unavailable, renamed: "markdownUnorderedListMarker", message: "Use markdownUnorderedListMarker instead.")
    @available(tvOS, unavailable, renamed: "markdownUnorderedListMarker", message: "Use markdownUnorderedListMarker instead.")
    @available(watchOS, unavailable, renamed: "markdownUnorderedListMarker", message: "Use markdownUnorderedListMarker instead.")
    @available(visionOS, unavailable, renamed: "markdownUnorderedListMarker", message: "Use markdownUnorderedListMarker instead.")
    @_documentation(visibility: internal)
    nonisolated public func markdownUnorderedListBullet(
        _ bullet: String
    ) -> some View {
        self
    }
}
