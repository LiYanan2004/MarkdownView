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
        LaTeX(configuration.wrappedString)
            .renderingStyle(.empty)
            .blockMode(.blockText)
            .font(configuration.environments.markdownRendererConfiguration.fontGroup.inlineMath)
            .frame(maxWidth: .infinity)
        #else
        Text(configuration.text)
            .font(font)
            .frame(maxWidth: .infinity)
        #endif
    }
}
