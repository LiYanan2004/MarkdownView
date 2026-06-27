//
//  MarkdownReader.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Markdown
import SwiftUI

/// A reader that provides a parsed markdown document to use across multiple views.
///
/// This reader offers a single source-of-truth for its child markdown views, and ensures the input is only parsed once. Apply parse-affecting modifiers, such as `markdownMathRenderingEnabled()`, to the reader so they can participate in parsing before the document is produced.
///
/// ```swift
/// MarkdownReader("**Hello World**") { markdown in
///     MarkdownView(markdown)
///     MarkdownTableOfContentReader(markdown) { headings in
///         // ...
///     }
/// }
/// ```
public struct MarkdownReader<Content: View>: View {
    private var sourceText: String
    private var contents: (_ document: Markdown.Document) -> Content

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownElementRenderers) private var elementRenderers

    public init(_ text: String, @ViewBuilder contents: @escaping (Markdown.Document) -> Content) {
        self.sourceText = text
        self.contents = contents
    }
    
    public var body: some View {
        let renderingInput = MarkdownRenderingInput(
            source: .rawText(sourceText),
            configuration: configuration,
            elementRenderers: elementRenderers
        )
        contents(renderingInput.document)
            .environment(\.markdownRendererConfiguration, renderingInput.configuration)
    }
}

#Preview {
    MarkdownReader("**Hello World**") { markdown in
        MarkdownView(markdown)
        MarkdownTableOfContentReader(markdown) { headings in
            
        }
    }
}
