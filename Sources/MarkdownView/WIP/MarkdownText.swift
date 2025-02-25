//
//  MarkdownText.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/12.
//

import SwiftUI

internal struct MarkdownText: View {
    private var content: MarkdownContent
    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.colorScheme) private var colorScheme
    private var renderConfiguration: MarkdownRenderConfiguration {
        configuration.with(\.colorScheme, colorScheme)
    }
    
    public init(_ text: String) {
        content = MarkdownContent(raw: .plainText(text))
    }
    
    @_spi(WIP)
    public init(_ url: URL) {
        content = MarkdownContent(raw: .url(url))
    }
    
    public var body: some View {
        MarkdownTextRenderer
            .walkDocument(content.document)
            .render(configuration: renderConfiguration)
        // TODO: Loading Image async and replace placeholder node.
        /*
            .onChange(of: content, initial: true) {
                Task.detached {
                    var documentNode = MarkdownTextRenderer
                        .walkDocument(content.document)
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

// MARK: - Preview

#Preview {
    let markdown = #"""
    ## Apple
    
    Here is the [Apple](https://www.apple.com) *website*.
    
    ### SwiftUI
    
    `SwiftUI` is Apple's **declaritive**, **cross-platform** UI framework.
    
    Here is a basic example, it shows:
    - how to create a simple view
      - The body is an opaque type of `View`
    
    ```swift
    import SwiftUI
    
    struct ContentView: View {
        var body: some View {
            EmptyView()
        }
    }
    ```
    """#
    MarkdownText(markdown)
        .textSelectionEnabledIfPossible()
        .padding()
        .lineSpacing(8)
}

fileprivate extension View {
    @ViewBuilder
    func textSelectionEnabledIfPossible(_ enabled: Bool = true) -> some View {
        #if os(macOS) || os(iOS)
        if #available(iOS 15.0, macOS 12.0, *), enabled {
            textSelection(.enabled)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
