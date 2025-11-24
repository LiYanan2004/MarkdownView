//
//  MarkdownReader.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

/// A reader that provides markdown content to use across multiple views.
///
/// This reader offers a single source of truth for its child markdown views so
/// the same Markdown source flows through the hierarchy.
///
/// ```swift
/// MarkdownReader("**Hello World**") { markdown in
///     MarkdownView(markdown)
///     MarkdownTableOfContent(markdown) { headings in
///         // ...
///     }
/// }
/// ```
public struct MarkdownReader<Content: View>: View {
    @ObservedObject private var content: MarkdownContent
    private var _body: (_ markdownContent: MarkdownContent) -> Content
    
    public init(
        _ text: String,
        @ViewBuilder contents: @escaping (MarkdownContent) -> Content
    ) {
        content = MarkdownContent(text)
        self._body = contents
    }
    
    public init(
        _ url: URL,
        @ViewBuilder contents: @escaping (MarkdownContent) -> Content
    ) {
        content = MarkdownContent(url)
        self._body = contents
    }
    
    public var body: some View {
        _body(content)
    }
}

#Preview {
    MarkdownReader("**Hello World**") { markdown in
        MarkdownView(markdown)
        MarkdownTableOfContent(markdown) { headings in
            
        }
    }
}
