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
    
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    var body: some View {
        VStack(alignment: .leading, spacing: configuration.componentSpacing) {
            ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                CmarkNodeVisitor(configuration: configuration)
                    .makeBody(for: child)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(configuration.fontGroup.blockQuote)
        .padding(.horizontal, 20)
        .background {
            configuration.blockQuoteTintColor
                .opacity(0.1)
        }
        .overlay(alignment: .leading) {
            configuration.blockQuoteTintColor
                .frame(width: 4)
        }
        .clipShape(.rect(cornerRadius: 3))
    }
}
