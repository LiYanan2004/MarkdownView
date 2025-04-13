//
//  MarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/13.
//

import SwiftUI

/// A type that renders images.
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

/// The properties of a markdown image.
public struct MarkdownImageRendererConfiguration: Sendable {
    public var url: URL
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
