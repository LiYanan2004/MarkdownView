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
    @Environment(\.markdownRendererConfiguration.fontGroup.inlineMath) private var font
    
    func makeBody(configuration: Configuration) -> some View {
        #if canImport(LaTeXSwiftUI)
        LaTeX(configuration.text)
            .renderingStyle(.wait)
            .font(font)
        #else
        Text(configuration.text)
            .font(font)
            .frame(maxWidth: .infinity)
        #endif
    }
}
