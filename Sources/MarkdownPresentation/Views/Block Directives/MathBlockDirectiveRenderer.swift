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

package struct MathBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    package init() { }

    package func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
        if let identifierValue = configuration.arguments.first?.value,
           let identifier = UUID(uuidString: identifierValue) {
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
        math.displayMathStorage?[mathIdentifier]
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
                .renderingStyle(.wait)
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
