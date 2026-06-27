//
//  MarkdownDisplayMathView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI

struct MarkdownDisplayMathView: View {
    var mathIdentifier: UUID
    
    @Environment(\.markdownMathContext) var mathContext
    @Environment(\.markdownFontGroup.displayMath) private var font
    
    private var latexMath: String? {
        mathContext?.displayMathStorage[mathIdentifier]
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            latex
            ScrollView(.horizontal) {
                latex
            }
        }
    }
    
    @ViewBuilder
    private var latex: some View {
        #if canImport(SwiftMath)
        if let latexMath {
            SwiftMathView(
                latex: latexMath,
                font: font,
                labelMode: .display,
                textAlignment: .center
            )
            .fixedSize()
            .frame(maxWidth: .infinity)
        }
        #else
        EmptyView()
        #endif
    }
}

#if canImport(SwiftMath)
#Preview {
    SwiftMathView(
        latex: "$$\\int_{-\\infty}^{\\infty} e^{-x^2} dx = \\sqrt{\\pi}$$",
        font: PlatformFont.preferredFont(forTextStyle: .body),
        labelMode: .display,
        textAlignment: .center
    )
}
#endif
