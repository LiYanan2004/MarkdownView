//
//  MarkdownText.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI

/// A view that displays parsed HTML asynchronously.
///
/// Convert HTML into  `AttributedString` asynchronously to avoid `AttributeGraph` crash.
struct MarkdownText: View {
    var text: AttributedString
    @State private var resolvedString: AttributedString?
    @State private var lastInput: AttributedString?

    private var containsHTML: Bool {
        text.runs.contains { $0.isHTML ?? false }
    }

    init(_ text: AttributedString) {
        self.text = text
    }

    var body: some View {
        Text(resolvedString ?? text)
            .task(id: text) {
                guard containsHTML else {
                    resolvedString = nil
                    lastInput = text
                    return
                }
                guard text != lastInput else { return }
                lastInput = text

                var result = text
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
                        result.replaceSubrange(range, with: htmlAttrString)
                    }
                }
                resolvedString = result
            }
    }
}
