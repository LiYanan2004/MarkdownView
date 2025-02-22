//
//  MarkdownReader.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

public struct MarkdownReader<Content: View>: View {
    private var markdownContent: ParsedMarkdownContent
    public var viewContent: (_ markdownContent: ParsedMarkdownContent) -> Content
    
    public init(_ text: String, @ViewBuilder viewContent: @escaping (ParsedMarkdownContent) -> Content) {
        self.markdownContent = ParsedMarkdownContent(raw: .plainText(text))
        self.viewContent = viewContent
    }
    
    public init(_ url: URL, @ViewBuilder viewContent: @escaping (ParsedMarkdownContent) -> Content) {
        self.markdownContent =  ParsedMarkdownContent(raw: .url(url))
        self.viewContent = viewContent
    }
    
    public var body: some View {
        viewContent(markdownContent)
    }
}

#Preview {
    MarkdownReader("**Hello World**") { markdown in
        MarkdownView(markdown)
        MarkdownTableOfContent(markdown) { headings in
            
        }
    }
}
