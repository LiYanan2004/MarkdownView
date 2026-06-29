//
//  InlineMath.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/6/17.
//

#if ENABLE_MATH_RENDERING
import SwiftUI

struct InlineMath: View {
    var latexText: String
    @Environment(\.markdownFontGroup.inlineMath) private var font

    init(latexText: String) {
        self.latexText = latexText
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            SwiftMathView(
                latex: latexText,
                font: font,
                labelMode: .text,
                textAlignment: .left
            )
            ScrollView(.horizontal) {
                SwiftMathView(
                    latex: latexText,
                    font: font,
                    labelMode: .text,
                    textAlignment: .left
                )
            }
        }
    }
}

#endif
