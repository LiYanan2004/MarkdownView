#if canImport(RichText)
import SwiftUI

extension SwiftUI.View {
    func markdownTextAttachmentEnvironment(
        from converter: MDTextConverter
    ) -> some View {
        modifier(MarkdownTextAttachmentEnvironmentModifier(converter: converter))
    }
}

// MARK: - Auxiliary

fileprivate struct MarkdownTextAttachmentEnvironmentModifier: ViewModifier {
    let converter: MDTextConverter

    func body(content: Content) -> some View {
        content
            .environment(\.markdownRendererConfiguration, converter.configuration)
            .environment(\.markdownElementRenderers, converter.elementRenderers)
            .environment(\.markdownFontGroup, converter.fonts)
            .environment(\.blockQuoteStyle, converter.blockQuoteStyle)
            .environment(\.codeBlockStyle, converter.codeBlockStyle)
            .environment(\.markdownTableStyle, converter.tableStyle)
    }
}

#endif
