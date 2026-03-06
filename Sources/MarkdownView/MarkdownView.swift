import SwiftUI
import Markdown

/// A view that renders markdown content.
public struct MarkdownView: View {
    /// Owned content for the string/URL inits — created once, survives parent re‑renders.
    @StateObject private var ownedContent: MarkdownContent
    /// External content passed via ``init(_:)-MarkdownContent``.
    @ObservedObject private var externalContent: MarkdownContent
    /// Which source of truth to use.
    private var usesExternalContent: Bool

    private var content: MarkdownContent {
        usesExternalContent ? externalContent : ownedContent
    }

    @Environment(\.markdownRendererConfiguration) private var configuration
    @Environment(\.markdownViewRenderer) private var renderer
    @Environment(\.headingStyleGroup) private var headingStyleGroup

    /// Creates a view that renders given markdown string.
    /// - Parameter text: The markdown source to render.
    public init(_ text: String) {
        let content = MarkdownContent(text)
        _ownedContent = StateObject(wrappedValue: content)
        _externalContent = ObservedObject(wrappedValue: content)
        usesExternalContent = false
    }

    /// Creates a view that renders the markdown from a local file at given url.
    /// - Parameter url: The url to the markdown file to render.
    public init(_ url: URL) {
        let content = MarkdownContent(url)
        _ownedContent = StateObject(wrappedValue: content)
        _externalContent = ObservedObject(wrappedValue: content)
        usesExternalContent = false
    }

    /// Creates an instance that renders from a ``MarkdownContent`` .
    /// - Parameter content: The ``MarkdownContent`` to render.
    public init(_ content: MarkdownContent) {
        _ownedContent = StateObject(wrappedValue: content)
        _externalContent = ObservedObject(wrappedValue: content)
        usesExternalContent = true
    }

    public var body: some View {
        var config = configuration
        config.headingStyleGroup = headingStyleGroup
        return MarkdownRenderingView(
            content: content,
            configuration: config
        )
        .font(configuration.fonts[.body] ?? Font.body)
    }
}

/// A cache that stores the last rendered view alongside the inputs that
/// produced it. Because this is a reference type stored in `@State`, it
/// persists across body evaluations without triggering additional renders.
@MainActor
private final class RenderCache {
    var raw: MarkdownContent.Raw?
    var configuration: MarkdownRendererConfiguration?
    var rendered: AnyView = AnyView(EmptyView())
}

/// An inner view that caches the rendered output.
///
/// Rendering is skipped when the markdown source and configuration
/// have not changed since the last evaluation.
private struct MarkdownRenderingView: View {
    let content: MarkdownContent
    let configuration: MarkdownRendererConfiguration

    @Environment(\.markdownViewRenderer) private var renderer
    @State private var cache = RenderCache()

    var body: some View {
        let currentRaw = (try? content.markdown).map { MarkdownContent.Raw.plainText($0) }
        if currentRaw != cache.raw || configuration != cache.configuration {
            let rendered = renderer
                .makeBody(content: content, configuration: configuration)
                .erasedToAnyView()
            cache.raw = currentRaw
            cache.configuration = configuration
            cache.rendered = rendered
            return rendered
        }
        return cache.rendered
    }
}

@available(iOS 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        MarkdownView("Hello **World**")
            .markdownTextSelection(.enabled)
    }
    #if os(macOS) || os(iOS)
    .textSelection(.enabled)
    #endif
    .padding()
}
