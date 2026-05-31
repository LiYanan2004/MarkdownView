//
//  MarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/13.
//

import SwiftUI

/// A type that renders images.
///
/// Think of this type as a SwiftUI View wrapper.
///
/// Don't directly access view dependencies (e.g. `@Environment`), use a separate view instead.
public protocol MarkdownImageRenderer: MarkdownElementRenderer where Configuration == MarkdownImageRendererConfiguration {
    associatedtype Configuration = MarkdownImageRendererConfiguration
}

/// The properties of a markdown image.
public struct MarkdownImageRendererConfiguration: Sendable {
    /// The source url of an image.
    public var url: URL
    /// The alternative text of an image.
    public var alternativeText: String?
}

// MARK: - Type Erasure

/// A type-erasure for type conforms to `MarkdownImageRenderer`.
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
