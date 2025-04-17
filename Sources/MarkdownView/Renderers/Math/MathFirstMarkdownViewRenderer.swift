//
//  MathFirstMarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI

struct MathFirstMarkdownViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        var rawText = content.raw.text
        let mathParser = MathParser(text: rawText)
    
        var configuration = configuration
        for math in mathParser.mathRepresentations.reversed() where !math.kind.inline {
            let mathIdentifier = configuration.math.appendDisplayMath(
                rawText[math.range]
            )
            
            rawText.replaceSubrange(
                math.range,
                with: "@math(uuid:\(mathIdentifier))"
            )
        }
        
        let _content = MarkdownContent(raw: .plainText(rawText))
        return CmarkFirstMarkdownViewRenderer()
            .makeBody(content: _content, configuration: configuration)
    }
}
