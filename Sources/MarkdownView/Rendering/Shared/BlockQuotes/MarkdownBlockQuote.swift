//
//  MarkdownBlockQuote.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

struct MarkdownBlockQuote: View {
    var content: MarkdownBlockQuoteStyleConfiguration.Content
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle

    init(content: MarkdownBlockQuoteStyleConfiguration.Content) {
        self.content = content
    }
    
    var body: some View {
        let configuration = MarkdownBlockQuoteStyleConfiguration(
            content: content
        )
        blockQuoteStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
