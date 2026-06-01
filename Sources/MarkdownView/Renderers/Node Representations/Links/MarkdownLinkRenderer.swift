import Foundation
import SwiftUI

/// A type that renders markdown links for a specific URL scheme.
public protocol MarkdownLinkRenderer: MarkdownElementRenderer where Configuration == MarkdownLinkRendererConfiguration {
    associatedtype Configuration = MarkdownLinkRendererConfiguration
}

/// The values that describe a markdown link.
public struct MarkdownLinkRendererConfiguration {
    /// The destination URL of the link.
    public var url: URL
    private var renderedLabel: AnyView

    /// The label generated from the markdown link contents.
    public var label: some View {
        renderedLabel
    }

    init<Label: View>(url: URL, label: Label) {
        self.url = url
        self.renderedLabel = label.erasedToAnyView()
    }
}
