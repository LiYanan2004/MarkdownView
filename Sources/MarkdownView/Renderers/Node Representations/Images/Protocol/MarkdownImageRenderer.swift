//
//  MarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/13.
//

import SwiftUI

/// A type that renders Markdown image nodes for a specific URL scheme.
///
/// The protocol mirrors SwiftUI’s `View` construction model: implement
/// ``MarkdownImageRenderer/makeBody(configuration:)`` and return a view hierarchy
/// that knows how to fetch and display the requested image. The method is
/// invoked on the main actor, so heavy work (networking, decoding, etc.) should
/// be delegated to another view or task.
///
/// > Tip: Because protocol witnesses cannot use property wrappers, keep the
/// > renderer itself lightweight and move any `@Environment` or `@State`
/// > dependencies into a nested SwiftUI view.
@preconcurrency
@MainActor
public protocol MarkdownImageRenderer {
    /// A type that represents the image.
    associatedtype Body: View
    
    /// Creates a view that represents the image.
    /// - parameter configuration: The properties of a markdown image.
    @preconcurrency
    @MainActor
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
    
    /// The properties of a markdown image.
    typealias Configuration = MarkdownImageRendererConfiguration
}

/// The immutable properties of a Markdown image node.
public struct MarkdownImageRendererConfiguration: Sendable {
    /// The source url of an image.
    ///
    /// When the original Markdown uses a relative path and a base URL was
    /// provided via ``View/markdownBaseURL(_:)``, this value already contains the
    /// resolved absolute URL. Otherwise it is the URL verbatim from the Markdown.
    public var url: URL
    /// The alternative text of an image.
    ///
    /// MarkdownView automatically suppresses the alternative text when the image
    /// appears inside a link so you can decide how to expose descriptive text.
    public var alternativeText: String?
}

// MARK: - Type Erasure

/// A type-erased wrapper for any ``MarkdownImageRenderer`` implementation.
public struct AnyMarkdownImageRenderer: MarkdownImageRenderer {
    public typealias Body = AnyView
    
    private let _makeBody: (Configuration) -> Body
    
    public init<D: MarkdownImageRenderer>(erasing renderer: D) {
        _makeBody = {
            renderer
                .makeBody(configuration: $0)
                .erasedToAnyView()
        }
    }
    
    public init<D: MarkdownImageRenderer>(_ renderer: D) {
        _makeBody = {
            renderer
                .makeBody(configuration: $0)
                .erasedToAnyView()
        }
    }
    
    public func makeBody(configuration: Configuration) -> AnyView {
        _makeBody(configuration)
    }
}
