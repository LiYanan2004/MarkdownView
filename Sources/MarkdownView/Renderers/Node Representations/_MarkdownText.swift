//
//  _MarkdownText.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI

/// A view that displays parsed HTML asynchronously.
///
/// Convert HTML into  `AttributedString` asynchronously to avoid `AttributeGraph` crash.
struct _MarkdownText: View {
    var text: AttributedString
    @State private var renderedState: RenderedState?
    
    init(_ text: AttributedString) {
        self.text = text
    }

    var body: some View {
        Text(Self.visibleText(input: text, rendered: renderedState))
            .task(id: text) {
                let renderedState = Self.renderedState(for: text)
                guard !Task.isCancelled else { return }
                self.renderedState = renderedState
            }
    }

    static func visibleText(input: AttributedString, rendered: RenderedState?) -> AttributedString {
        guard let rendered, rendered.input == input else {
            return input
        }
        return rendered.output
    }

    static func renderedState(for text: AttributedString) -> RenderedState {
        RenderedState(
            input: text,
            output: renderedText(from: text)
        )
    }

    static func renderedText(from text: AttributedString) -> AttributedString {
        var attributedString = text
        for run in text.runs.reversed() where (run.isHTML ?? false) {
            let range = run.range

            if let htmlAttrString = try? AttributedString(
                NSAttributedString(
                    data: Data(String(text.characters[range]).utf8),
                    options: [
                        .documentType: NSAttributedString.DocumentType.html
                    ],
                    documentAttributes: nil
                )
            ) {
                attributedString.replaceSubrange(range, with: htmlAttrString)
            }
        }
        return attributedString
    }

    struct RenderedState {
        var input: AttributedString
        var output: AttributedString
    }
}
