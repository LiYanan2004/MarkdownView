//
//  MarkdownBlockQuote.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

package struct MarkdownBlockQuote: View {
    package var content: MarkdownBlockQuoteStyleConfiguration.Content
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle

    package init(content: MarkdownBlockQuoteStyleConfiguration.Content) {
        self.content = content
    }
    
    package var body: some View {
        let configuration = MarkdownBlockQuoteStyleConfiguration(
            content: content
        )
        blockQuoteStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
