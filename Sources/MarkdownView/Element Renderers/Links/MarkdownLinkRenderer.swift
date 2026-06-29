import SwiftUI

/// A type that renders markdown links for a specific URL scheme.
///
/// Register a link renderer when links with a custom URL scheme should use app-specific navigation or presentation. MarkdownView keeps normal links as SwiftUI links when no renderer is registered for the URL scheme.
///
/// Keep environment-dependent work in a separate `View`. The renderer is a factory object, so a nested view is the correct place to read `@Environment(\.openURL)` or app navigation state.
///
/// The following example handles links such as `[Open settings](app://settings)` with a custom button.
///
/// ```swift
/// struct AppLinkRenderer: MarkdownLinkRenderer {
///     func makeBody(configuration: Configuration) -> some View {
///         AppLinkView(configuration: configuration)
///     }
/// }
///
/// private struct AppLinkView: View {
///     let configuration: MarkdownLinkRendererConfiguration
///
///     @Environment(\.openURL) private var openURL
///
///     var body: some View {
///         Button {
///             openURL(configuration.url)
///         } label: {
///             configuration.label
///         }
///     }
/// }
///
/// MarkdownView("[Open settings](app://settings)")
///     .markdownElementRenderer(.link(AppLinkRenderer(), urlScheme: "app"))
/// ```
public protocol MarkdownLinkRenderer: MarkdownElementRenderer where Configuration == MarkdownLinkRendererConfiguration {
    associatedtype Configuration = MarkdownLinkRendererConfiguration
}
