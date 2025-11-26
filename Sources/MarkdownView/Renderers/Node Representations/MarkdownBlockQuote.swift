//
//  MarkdownBlockQuote.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/22.
//

import SwiftUI
import Markdown

struct MarkdownBlockQuote: View {
    var blockQuote: BlockQuote
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle
    
    var body: some View {
        let configuration = BlockQuoteStyleConfiguration(
            content: BlockQuoteStyleConfiguration.Content(blockQuote: blockQuote)
        )
        blockQuoteStyle
            .makeBody(configuration: configuration)
            .erasedToAnyView()
    }
}
