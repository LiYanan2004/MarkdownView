//
//  MarkdownViewRenderer.BlockQuote.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI
import Markdown

extension MarkdownViewRenderer {
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        Result {
            let contents = contents(of: blockQuote)
            VStack(alignment: .leading, spacing: configuration.componentSpacing) {
                ForEach(contents.indices, id: \.self) { index in
                    contents[index].content
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
}
