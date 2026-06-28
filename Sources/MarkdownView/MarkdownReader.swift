//
//  MarkdownReader.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import Markdown
import SwiftUI

/// A reader that provides a parsed markdown result to use across multiple views.
///
/// This reader offers a single source-of-truth for its child markdown views, and ensures the input is only parsed once. Apply parse-affecting modifiers, such as `markdownMathRenderingEnabled()`, to the reader so they can participate in parsing before the parse result is produced.
///
/// ```swift
/// MarkdownReader("**Hello World**") { parseResult in
///     MarkdownView(parseResult)
///     MarkdownTableOfContentReader(parseResult) { headings in
///         // ...
///     }
/// }
/// ```
public struct MarkdownReader<Content: View>: View {
    private var sourceText: String
    private var content: (_ parseResult: MarkdownParseResult) -> Content

    @Environment(\.markdownMathContext) private var mathContext
    @Environment(\.markdownElementRenderers) private var elementRenderers

    /// Creates a reader that parses a markdown string once and passes the parse result to `content`.
    ///
    /// - Parameters:
    ///   - text: The markdown source to parse.
    ///   - content: A view builder that receives the parse result.
    public init(_ text: String, @ViewBuilder content: @escaping (MarkdownParseResult) -> Content) {
        self.sourceText = text
        self.content = content
    }
    
    public var body: some View {
        let request = MarkdownParseRequest(
            sourceText: sourceText,
            mathContext: mathContext,
            elementRenderers: elementRenderers
        )
        let parseResult = MarkdownDocumentParser.parse(request)

        content(parseResult)
            .environment(\.markdownMathContext, parseResult.mathContext)
    }
}

#Preview {
    MarkdownReader("**Hello World**") { parseResult in
        MarkdownView(parseResult)
        MarkdownTableOfContentReader(parseResult) { headings in
            
        }
    }
}
