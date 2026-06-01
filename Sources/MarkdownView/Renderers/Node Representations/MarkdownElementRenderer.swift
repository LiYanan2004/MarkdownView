//
//  MarkdownElementRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/5/31.
//

import SwiftUI

/// A registration that associates a markdown element with a custom renderer.
public enum MarkdownElementRendererRegistration {
    /// Registers a renderer for a block directive with the specified name.
    case blockDirective(any BlockDirectiveRenderer, name: String)
    /// Registers a renderer for images that use the specified URL scheme.
    case image(any MarkdownImageRenderer, urlScheme: String)
    /// Registers a renderer for links that use the specified URL scheme.
    case link(any MarkdownLinkRenderer, urlScheme: String)
    
    var renderer: any MarkdownElementRenderer {
        switch self {
            case .blockDirective(let renderer, _): renderer
            case .image(let renderer, _): renderer
            case .link(let renderer, _): renderer
        }
    }

    var blockDirective: (name: String, renderer: any BlockDirectiveRenderer)? {
        if case .blockDirective(let renderer, let name) = self {
            return (name, renderer)
        }
        return nil
    }

    var image: (scheme: String, renderer: any MarkdownImageRenderer)? {
        if case .image(let renderer, let scheme) = self {
            return (scheme, renderer)
        }
        return nil
    }

    var link: (scheme: String, renderer: any MarkdownLinkRenderer)? {
        if case .link(let renderer, let scheme) = self {
            return (scheme, renderer)
        }
        return nil
    }
}

/// A type that creates a view for a markdown element.
///
/// Use one of the specialized renderer protocols, such as ``MarkdownImageRenderer``, ``MarkdownLinkRenderer``, or ``BlockDirectiveRenderer``, to adopt this protocol with the correct configuration type.
@preconcurrency
@MainActor
public protocol MarkdownElementRenderer {
    /// The input that describes the markdown element to render.
    associatedtype Configuration
    /// The view that represents the rendered markdown element.
    associatedtype Body: View

    /// Creates the view for the specified markdown element.
    ///
    /// - Parameter configuration: The values that describe the markdown element.
    /// - Returns: A view that renders the markdown element.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}

// MARK: - Environment Values

struct MarkdownElementRenderersEnvironmentKey: EnvironmentKey {
    nonisolated(unsafe) static let defaultValue: [MarkdownElementRendererRegistration] = []
}

extension EnvironmentValues {
    var markdownElementRenderers: [MarkdownElementRendererRegistration] {
        get { self[MarkdownElementRenderersEnvironmentKey.self] }
        set { self[MarkdownElementRenderersEnvironmentKey.self] = newValue }
    }
}

// MARK: - Registration Management

extension MarkdownElementRendererRegistration {
    func matches(_ other: MarkdownElementRendererRegistration) -> Bool {
        switch (self, other) {
        case (.blockDirective(_, let name), .blockDirective(_, let otherName)):
            return name == otherName
        case (.image(_, let urlScheme), .image(_, let otherURLScheme)):
            return urlScheme == otherURLScheme
        case (.link(_, let urlScheme), .link(_, let otherURLScheme)):
            return urlScheme == otherURLScheme
        default:
            return false
        }
    }
}

extension Array where Element == MarkdownElementRendererRegistration {
    mutating func register(_ registration: MarkdownElementRendererRegistration) {
        if let existingRendererIndex = firstIndex(where: { $0.matches(registration) }) {
            self[existingRendererIndex] = registration
        } else {
            append(registration)
        }
    }
}
