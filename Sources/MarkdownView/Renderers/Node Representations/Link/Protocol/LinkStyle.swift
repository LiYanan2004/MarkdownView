//
//  LinkStyle.swift
//  MarkdownView
//
//  Created by Mahdi BND on 11/17/25.
//

import SwiftUI

/// A type that applies a custom style to all links within a MarkdownView.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
@preconcurrency
@MainActor
public protocol LinkStyle {
    /// A view that represents the current link.
    associatedtype Body: View
    /// Creates the view that represents the current link.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The optional action to perform when URL is tapped.
    @preconcurrency
    func action(_ url: URL) -> Void

    /// The properties of a link.
    typealias Configuration = LinkStyleConfiguration
}

/// The properties of a link.
public struct LinkStyleConfiguration {
    /// The destination URL of the link.
    public var destination: String?
    /// The optional title specified in markdown (may be nil).
    public var title: String?

    public init(destination: String?, title: String?) {
        self.destination = destination
        self.title = title
    }
}

// MARK: - Environment Value

struct LinkStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any LinkStyle = DefaultLinkStyle()
}

extension EnvironmentValues {
    package var linkStyle: any LinkStyle {
        get { self[LinkStyleKey.self] }
        set { self[LinkStyleKey.self] = newValue }
    }
}
