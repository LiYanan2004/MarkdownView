//
//  MarkdownReader.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

/// A reader that provides a markdown content to use across multiple views.
///
/// This reader offers a single source-of-truth for its child markdown views, and ensures the input is only parsed once.
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
    private var markdownContent: MarkdownContent
    private var contents: (_ markdownContent: MarkdownContent) -> Content
    
    public init(_ text: String, @ViewBuilder contents: @escaping (MarkdownContent) -> Content) {
        self.markdownContent = MarkdownContent(raw: .plainText(text))
        self.contents = contents
    }
    
    @_spi(WIP)
    public init(_ url: URL, @ViewBuilder contents: @escaping (MarkdownContent) -> Content) {
        self.markdownContent =  MarkdownContent(raw: .url(url))
        self.contents = contents
    }
    
    public var body: some View {
        contents(markdownContent)
    }
}

#Preview {
    MarkdownReader("**Hello World**") { markdown in
        MarkdownView(markdown)
        MarkdownTableOfContent(markdown) { headings in
            
        }
    }
}
