//
//  MarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/4/13.
//

import SwiftUI

/// A type that renders markdown images for a specific URL scheme.
///
/// Register an image renderer when a subset of image URLs should use app-specific loading, layout, caching, or interaction behavior. The renderer receives the resolved URL and the image alternative text from the markdown source.
///
/// Keep environment-dependent work in a separate `View`. The renderer is a factory object, so a nested view is the correct place to read `@Environment` values or attach async image loading state.
///
/// The following example renders images with the `asset` scheme from an asset catalog. The markdown image `![Logo](asset://AppLogo)` matches the `asset` registration.
///
/// ```swift
/// struct AssetCatalogImageRenderer: MarkdownImageRenderer {
///     func makeBody(configuration: Configuration) -> some View {
///         let imageName = configuration.url.host ?? configuration.url.lastPathComponent
///
///         Image(imageName)
///             .resizable()
///             .scaledToFit()
///             .accessibilityLabel(configuration.alternativeText ?? "")
///     }
/// }
///
/// MarkdownView("![Logo](asset://AppLogo)")
///     .markdownElementRenderer(.image(AssetCatalogImageRenderer(), urlScheme: "asset"))
/// ```
public protocol MarkdownImageRenderer: MarkdownElementRenderer where Configuration == MarkdownImageRendererConfiguration {
    associatedtype Configuration = MarkdownImageRendererConfiguration
}

// MARK: - Type Erasure

/// A type-erasure for type conforms to `MarkdownImageRenderer`.
public struct AnyMarkdownImageRenderer: MarkdownImageRenderer {
    public typealias Body = AnyView
    
    private let _makeBody: (Configuration) -> Body
    
    /// Creates a type-erased image renderer.
    ///
    /// - Parameter renderer: The renderer to erase.
    public init<D: MarkdownImageRenderer>(erasing renderer: D) {
        _makeBody = {
            renderer
                .makeBody(configuration: $0)
                .erasedToAnyView()
        }
    }
    
    /// Creates a type-erased image renderer.
    ///
    /// - Parameter renderer: The renderer to erase.
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
