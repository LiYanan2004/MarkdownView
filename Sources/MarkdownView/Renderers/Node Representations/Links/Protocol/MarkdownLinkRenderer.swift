import Foundation
import SwiftUI

@preconcurrency
@MainActor
public protocol MarkdownLinkRenderer {
    associatedtype Body: View

    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    typealias Configuration = MarkdownLinkRendererConfiguration
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
