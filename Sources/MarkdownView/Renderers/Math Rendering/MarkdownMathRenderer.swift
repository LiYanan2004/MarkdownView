//
//  MarkdownMathRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import Foundation
import SwiftUI
#if canImport(LaTeXSwiftUI)
import LaTeXSwiftUI
#endif

struct MarkdownMathRenderer: BlockDirectiveDisplayable {
    @Environment(\.markdownRendererConfiguration) private var configuration
    
    func makeView(arguments: [BlockDirectiveArgument], text: String) -> some View {
        LaTeX(text)
            .renderingStyle(.wait)
            .font(configuration.fontGroup.inlineMath)
    }
}
