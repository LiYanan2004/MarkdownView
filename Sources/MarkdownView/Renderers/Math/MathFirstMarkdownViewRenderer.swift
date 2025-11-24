//
//  MathFirstMarkdownViewRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/12.
//

import SwiftUI
import Markdown

struct MathFirstMarkdownViewRenderer: MarkdownViewRenderer {
    func makeBody(
        content: MarkdownContent,
        configuration: MarkdownRendererConfiguration
    ) -> some View {
        var configuration = configuration
        var rawText = content.raw.text
        
        var extractor = ParsingRangesExtractor()
        extractor.visit(content.parse(options: ParseOptions().union(.parseBlockDirectives)))
        for range in extractor.parsableRanges(in: rawText) {
            let segment = rawText[range]
            let segmentParser = MathParser(text: segment)
            for math in segmentParser.mathRepresentations.reversed() where !math.kind.inline {
                let mathIdentifier = configuration.math.appendDisplayMath(
                    rawText[math.range]
                )
                rawText.replaceSubrange(
                    math.range,
                    with: "@math(uuid:\(mathIdentifier))"
                )
            }
        }
        
        let _content = MarkdownContent(raw: .plainText(rawText))
        return CmarkFirstMarkdownViewRenderer()
            .makeBody(content: _content, configuration: configuration)
    }
}
