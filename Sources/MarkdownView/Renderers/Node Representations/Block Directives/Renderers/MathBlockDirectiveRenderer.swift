//
//  MathBlockDirectiveRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import Foundation
import SwiftUI
#if canImport(LaTeXSwiftUI)
import LaTeXSwiftUI
#endif

struct MathBlockDirectiveRenderer: BlockDirectiveRenderer {
    func makeBody(configuration: Configuration) -> some View {
        if let identifier = UUID(uuidString: configuration.arguments[0].value) {
            DisplayMath(mathIdentifier: identifier)
        } else {
            EmptyView()
        }
    }
}

fileprivate struct DisplayMath: View {
    var mathIdentifier: UUID
    @Environment(\.markdownFontGroup.displayMath) private var font
    @Environment(\.markdownRendererConfiguration.math) private var math
    private var latexMath: String? {
        math.displayMathStorage[mathIdentifier]
    }

    var body: some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            ViewThatFits(in: .horizontal) {
                latex
                ScrollView(.horizontal) {
                    latex
                }
            }
        } else {
            ScrollView(.horizontal) {
                latex
            }
        }
    }
    
    @ViewBuilder
    private var latex: some View {
        #if canImport(LaTeXSwiftUI)
        if let latexMath {
            LaTeX(latexMath)
                .renderingStyle(.empty)
                .ignoreStringFormatting()
                .blockMode(.blockText)
                .font(font)
                .frame(maxWidth: .infinity)
        }
        #else
        EmptyView()
        #endif
    }
}
