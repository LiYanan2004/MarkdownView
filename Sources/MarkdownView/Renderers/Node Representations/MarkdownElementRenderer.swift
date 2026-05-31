//
//  MarkdownElementRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/5/31.
//

import SwiftUI

public enum MarkdownElementRendererRegistration {
    case blockDirective(any BlockDirectiveRenderer, name: String)
    case image(any MarkdownImageRenderer, urlScheme: String)
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

@preconcurrency
@MainActor
public protocol MarkdownElementRenderer {
    associatedtype Configuration
    associatedtype Body: View

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
