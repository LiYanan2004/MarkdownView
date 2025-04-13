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
        if let identifier = UUID(uuidString: configuration.arguments[0].value),
           let mathExpression = MathStorage.lookupTable[identifier] {
            MathBlockView(mathExpression)
        } else {
            EmptyView()
        }
    }
}

fileprivate struct MathBlockView: View {
    var mathExpression: String
    @Environment(\.markdownRendererConfiguration.fontGroup.inlineMath) private var font
    
    init(_ exp: String) {
        self.mathExpression = exp
    }
    
    var body: some View {
        #if canImport(LaTeXSwiftUI)
        LaTeX(mathExpression)
            .renderingStyle(.empty)
            .ignoreStringFormatting()
            .blockMode(.blockText)
            .font(font)
            .frame(maxWidth: .infinity)
        #else
        EmptyView()
        #endif
    }
}
