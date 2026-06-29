import Foundation
import SwiftUI

/// The values that describe a markdown link.
public struct MarkdownLinkRendererConfiguration {
    /// The destination URL of the link.
    public var url: URL

    /// The label generated from the markdown link contents.
    public var label: AnyView

    init(url: URL, label: AnyView) {
        self.url = url
        self.label = label
    }
}

@available(*, unavailable)
extension MarkdownLinkRendererConfiguration: Sendable {
    
}
