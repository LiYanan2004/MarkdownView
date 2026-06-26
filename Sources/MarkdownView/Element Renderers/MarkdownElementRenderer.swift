//
//  MarkdownElementRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2026/5/31.
//

import SwiftUI

/// A type that creates a view for a markdown element.
///
/// Use one of the specialized renderer protocols, such as ``MarkdownImageRenderer``, ``MarkdownLinkRenderer``, or ``MarkdownBlockDirectiveRenderer``, to adopt this protocol with the correct configuration type.
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
