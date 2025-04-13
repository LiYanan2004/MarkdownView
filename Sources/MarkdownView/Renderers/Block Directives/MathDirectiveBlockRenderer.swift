//
//  MathDirectiveBlockRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import Foundation
import SwiftUI
#if canImport(LaTeXSwiftUI)
import LaTeXSwiftUI
#endif

struct MathDirectiveBlockRenderer: BlockDirectiveRenderer {
    func makeBody(configuration: Configuration) -> some View {
        #if canImport(LaTeXSwiftUI)
        if let identifier = UUID(uuidString: configuration.arguments[0].value),
           let mathExpression = MathStorage.lookupTable[identifier] {
            LaTeX(mathExpression)
                .renderingStyle(.empty)
                .ignoreStringFormatting()
                .blockMode(.blockText)
                .font(configuration.environments.markdownRendererConfiguration.fontGroup.inlineMath)
                .frame(maxWidth: .infinity)
        } else {
            EmptyView()
        }
        #else
        EmptyView()
        #endif
    }
}
