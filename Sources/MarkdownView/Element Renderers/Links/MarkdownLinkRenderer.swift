import SwiftUI

/// A type that renders markdown links for a specific URL scheme.
public protocol MarkdownLinkRenderer: MarkdownElementRenderer where Configuration == MarkdownLinkRendererConfiguration {
    associatedtype Configuration = MarkdownLinkRendererConfiguration
}
