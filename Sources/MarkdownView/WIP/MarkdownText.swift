//
//  MarkdownText.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

public struct MarkdownText: View {
    private var _parsedContent: ParsedMarkdownContent
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.colorScheme) private var colorScheme
    private var renderConfiguration: MarkdownRenderConfiguration {
        configuration.with(\.colorScheme, colorScheme)
    }
    
    public init(_ text: String) {
        _parsedContent = ParsedMarkdownContent(raw: .plainText(text))
    }
    
    public init(_ url: URL) {
        _parsedContent = ParsedMarkdownContent(raw: .url(url))
    }
    
    public var body: some View {
        MarkdownTextRenderer
            .walkDocument(_parsedContent.document)
            .render(configuration: renderConfiguration)
        // TODO: Loading Image async and replace placeholder node.
        /*
            .onChange(of: _parsedContent, initial: true) {
                Task.detached {
                    var documentNode = MarkdownTextRenderer
                        .walkDocument(_parsedContent.document)
                    await documentNode.modifyOverIteration { node in
                        guard node.kind == .placeholder,
                              case let .task(task) = node.content else {
                            return
                        }
                            
                        if let result = try? await task.value, let image = result as? Image {
                            node.kind = .image
                            node.content = .image(image)
                        }
                    }
                    await MainActor.run {
                        self.documentNodes = documentNode
                    }
                }
            }
         */
    }
}

#Preview {
    MarkdownText("""
    
    ## Hello World 
    
    Here is the [apple](https://www.apple.com) **website**.
    
    We are thril to introduce a new App called ***invites***.
    
    It uses `SwiftUI` framework.
    
    ```swift
    import SwiftUI
    
    struct ContentView: View {
        var body: some View {
            EmptyView()
        }
    }
    ```
    
    Hello
    
    """)
    .textSelection(.enabled)
    .padding()
    .lineSpacing(8)
}
