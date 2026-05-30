//
//  MarkdownLinkRenderer.swift
//  MarkdownView
//
//  Orbit fork addition. Mirrors `MarkdownImageRenderer` so consumers can
//  inject a custom view for inline links (e.g. favicon + URL hover tooltip).
//

import SwiftUI
import Foundation

/// A type that renders inline markdown links.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a
/// separate view instead.
@preconcurrency
@MainActor
public protocol MarkdownLinkRenderer: Equatable, Sendable {
    /// A type that represents the link.
    associatedtype Body: View

    /// Creates a view that represents the link.
    /// - parameter configuration: The properties of a markdown link, including
    ///   the destination `URL` and the already-styled default `label` view
    ///   (text + inline images + inline code as the library would render it).
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The properties of a markdown link.
    typealias Configuration = MarkdownLinkRendererConfiguration
}

/// The properties of a markdown link.
///
/// NOT `Sendable` — `label: AnyView` cannot be. Apple explicitly marks
/// `AnyView: Sendable` as `@available(*, unavailable)` in
/// `SwiftUICore.swiftinterface`. The image renderer's equivalent
/// (`MarkdownImageRendererConfiguration`) is `Sendable` only because its
/// fields are `URL + String?`. The renderer protocol above is
/// `@preconcurrency @MainActor` so the configuration never crosses an actor
/// boundary — `Sendable` isn't required.
public struct MarkdownLinkRendererConfiguration {
    /// The destination URL of the link.
    public var url: URL
    /// The already-styled default link contents (text, inline images,
    /// inline code, etc.) as the library would render them without a
    /// custom renderer. Wrap this in your custom view to preserve the
    /// surrounding inline formatting.
    public var label: AnyView
    /// Inline emphasis inherited from ancestor nodes (e.g. a link inside
    /// `**bold**` / `*italic*` / `~~strike~~`). The custom renderer's output is
    /// a SwiftUI View that can't be re-styled by the ancestor, so the renderer
    /// is responsible for reflecting this emphasis on its label — e.g. by
    /// selecting a bold/italic font. Empty when the link isn't emphasized.
    public var inlinePresentationIntent: InlinePresentationIntent = []
}

// MARK: - Type Erasure

/// Type-erased `MarkdownLinkRenderer`.
///
/// `Equatable` so it can live in `MarkdownRendererConfiguration` and
/// participate in renderer-cache invalidation: swapping the underlying
/// renderer for a given scheme changes the equality of the surrounding
/// `MarkdownRendererConfiguration`, which invalidates
/// `CmarkFirstMarkdownViewRenderer`'s view cache.
///
/// `@unchecked Sendable`: the protocol's `Sendable` requirement makes
/// `D: MarkdownLinkRenderer` automatically Sendable so the closure
/// captures of `renderer: D` are legal. The `@unchecked` is for the
/// `@MainActor` closure storage — Swift 6 strict mode flags
/// `@MainActor (...) -> AnyView` stored properties as non-Sendable
/// even though isolation guarantees they can only be called on
/// MainActor. We've manually verified safety.
public struct AnyMarkdownLinkRenderer: @unchecked Sendable, Equatable {
    let makeBody: @MainActor (MarkdownLinkRendererConfiguration) -> AnyView
    private let wrapped: Any
    private let isEqualTo: (Any) -> Bool

    public init<D: MarkdownLinkRenderer>(_ renderer: D) {
        self.wrapped = renderer
        self.makeBody = { config in
            renderer.makeBody(configuration: config).erasedToAnyView()
        }
        self.isEqualTo = { other in
            guard let other = other as? D else { return false }
            return other == renderer
        }
    }

    public static func == (lhs: AnyMarkdownLinkRenderer, rhs: AnyMarkdownLinkRenderer) -> Bool {
        lhs.isEqualTo(rhs.wrapped)
    }
}
