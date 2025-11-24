//
//  BlockDirectiveRendererModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

extension View {
    /// Registers a custom renderer for a block directive name.
    ///
    /// Block directives (`::name{}`) are only rendered when a matching renderer
    /// exists and the name is present in the allow list. This modifier performs
    /// both tasks for you: it stores the renderer in the shared registry (the
    /// last registration wins for the same name, comparisons are
    /// case-insensitive) and it inserts the name into the environment’s
    /// allow list. Directives without a renderer fall back to rendering their
    /// body with the default Markdown visitor.
    ///
    /// ```swift
    /// struct CalloutDirective: BlockDirectiveRenderer {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         Label(configuration.arguments.first?.value ?? "Info",
    ///               systemImage: "info.circle")
    ///             .padding()
    ///             .background(RoundedRectangle(cornerRadius: 8).fill(.blue.opacity(0.1)))
    ///     }
    /// }
    ///
    /// MarkdownView(markdown)
    ///     .blockDirectiveRenderer(CalloutDirective(), for: "callout")
    /// // Markdown: ::callout[level:warning]{ ... }
    /// ```
    ///
    /// - Parameters:
    ///   - renderer: The renderer responsible for producing the SwiftUI view.
    ///   - name: The directive name to match. Use lowercase names to avoid
    ///     collisions with existing renderers.
    nonisolated public func blockDirectiveRenderer(
        _ renderer: some BlockDirectiveRenderer,
        for name: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            BlockDirectiveRenderers.shared.addRenderer(renderer, for: name)
            configuration.allowedBlockDirectiveRenderers.insert(name)
        }
    }
}
