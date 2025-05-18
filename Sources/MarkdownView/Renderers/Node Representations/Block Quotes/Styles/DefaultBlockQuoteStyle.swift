//
//  DefaultBlockQuoteStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// Default block quote style that applies to a MarkdownView.
public struct DefaultBlockQuoteStyle: BlockQuoteStyle {
    public func makeBody(configuration: Configuration) -> some View {
        DefaultBlockQuoteView(configuration: configuration)
    }
}

extension BlockQuoteStyle where Self == DefaultBlockQuoteStyle {
    /// Default block quote style.
    static public var `default`: DefaultBlockQuoteStyle { .init() }
}

fileprivate struct DefaultBlockQuoteView: View {
    var configuration: BlockQuoteStyleConfiguration
    @Environment(\.markdownFontGroup.blockQuote) private var font
    @Environment(\.markdownRendererConfiguration.blockQuoteTintColor) private var tint
    var body: some View {
        configuration.content
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(font)
            .padding(.horizontal, 20)
            .background {
                tint.opacity(0.1)
            }
            .overlay(alignment: .leading) {
                tint.frame(width: 4)
            }
            .clipShape(.rect(cornerRadius: 3))
    }
}
