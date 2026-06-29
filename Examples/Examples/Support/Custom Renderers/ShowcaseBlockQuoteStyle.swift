//
//  ShowcaseBlockQuoteStyle.swift
//  Examples
//

import MarkdownView
import SwiftUI

struct ShowcaseBlockQuoteStyle: MarkdownBlockQuoteStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.teal)
                .frame(width: 4)

            configuration.content
        }
        .padding(.vertical, 6)
    }
}
