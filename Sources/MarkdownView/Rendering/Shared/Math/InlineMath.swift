//
//  InlineMath.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/17.
//

#if canImport(LaTeXSwiftUI)
import SwiftUI
import LaTeXSwiftUI

struct InlineMath: View {
    var latexText: String
    @Environment(\.markdownFontGroup.inlineMath) private var font

    init(latexText: String) {
        self.latexText = latexText
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            LaTeX(latexText)
                .font(font.asPlatformFont)
                .renderingStyle(.wait)
                .blockMode(.alwaysInline)
            ScrollView(.horizontal) {
                LaTeX(latexText)
                    .font(font.asPlatformFont)
                    .renderingStyle(.wait)
                    .blockMode(.alwaysInline)
            }
        }
    }
}

#endif
