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
    @Environment(\.markdownRendererConfiguration.fontGroup.displayMath) private var font
    @Environment(\.markdownRendererConfiguration.math) private var math
    private var latexMath: String? {
        math.displayMathStorage?[mathIdentifier]
    }

    var body: some View {
        #if canImport(LaTeXSwiftUI)
        if let latexMath {
            LaTeX(latexMath)
                .renderingStyle(.empty)
                .ignoreStringFormatting()
                .blockMode(.blockText)
                .font(font)
                .frame(maxWidth: .infinity)
        } else {
            EmptyView()
        }
        #else
        EmptyView()
        #endif
    }
}
