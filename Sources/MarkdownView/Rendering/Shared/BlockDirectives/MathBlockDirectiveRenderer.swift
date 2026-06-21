//
//  MathBlockDirectiveRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import Foundation
import SwiftUI

struct MathBlockDirectiveRenderer: MarkdownBlockDirectiveRenderer {
    init() { }

    func makeBody(configuration: MarkdownBlockDirectiveRendererConfiguration) -> some View {
        if let identifierValue = configuration.arguments.first(where: { $0.name == "uuid" })?.value,
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
