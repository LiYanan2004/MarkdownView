//
//  MarkdownView.Role.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation

extension MarkdownView {
    /// The role of MarkdownView, which affects how MarkdownView is rendered.
    public enum Role: Sendable, Hashable {
        /// The normal role.
        ///
        /// A role that makes the view take the space it needs and center contents, like a normal SwiftUI View.
        case normal
        /// The editor role.
        ///
        /// A role that makes the view take the maximum space
        /// and align its content in the top-leading, just like an editor.
        ///
        /// A Markdown Editor typically use this mode to provide a Live Preview.
        ///
        /// - note: Editor mode is unsupported on watchOS.
        case editor
    }
}
