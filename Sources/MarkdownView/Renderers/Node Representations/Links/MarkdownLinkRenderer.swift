import Foundation
import SwiftUI

public protocol MarkdownLinkRenderer: MarkdownElementRenderer where Configuration == MarkdownLinkRendererConfiguration {
    associatedtype Configuration = MarkdownLinkRendererConfiguration
}

public struct MarkdownLinkRendererConfiguration {
    public var url: URL
    private var renderedLabel: AnyView

    public var label: some View {
        renderedLabel
    }

    init<Label: View>(url: URL, label: Label) {
        self.url = url
        self.renderedLabel = label.erasedToAnyView()
    }
}
