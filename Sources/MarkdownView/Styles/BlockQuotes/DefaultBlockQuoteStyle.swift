//
//  DefaultBlockQuoteStyle.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2025/4/17.
//

import SwiftUI

/// Default block quote style that applies to a MarkdownView.
public struct DefaultBlockQuoteStyle: MarkdownBlockQuoteStyle {
    public func makeBody(configuration: Configuration) -> some View {
        DefaultBlockQuoteView(configuration: configuration)
    }
}

extension MarkdownBlockQuoteStyle where Self == DefaultBlockQuoteStyle {
    /// Default block quote style.
    static public var `default`: DefaultBlockQuoteStyle { .init() }
}

fileprivate struct DefaultBlockQuoteView: View {
    var configuration: MarkdownBlockQuoteStyleConfiguration
    
    @Environment(\.markdownRendererConfiguration) private var rendererConfiguration
    @Environment(\.markdownFontGroup.blockQuote) private var font
    
    var body: some View {
        let tintColor = rendererConfiguration.tintColors[.blockQuote, default: .accentColor]
        configuration.content
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(font._swiftUIFont)
            .padding(.horizontal, 20)
            .background {
                tintColor.opacity(0.1)
            }
            .overlay(alignment: .leading) {
                tintColor.frame(width: 4)
            }
            .clipShape(.rect(cornerRadius: 3))
    }
}
