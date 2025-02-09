//
//  RenderingModeModifier.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/2/9.
//

import SwiftUI

/// A Markdown Rendering Mode
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(visionOS, unavailable)
@available(macCatalyst, unavailable)
@available(watchOS, unavailable)
public enum MarkdownRenderingMode: Sendable {
    /// Immediately re-render markdown view when text changes.
    case immediate
    /// Re-render markdown view efficiently by adding a debounce to the pipeline.
    ///
    /// When input markdown text is heavy and will be modified in real time, use this mode will help you reduce CPU usage thus saving battery life.
    case optimized
}

extension View {
    /// MarkdownView rendering mode.
    ///
    /// - Parameter renderingMode: Markdown rendering mode.
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(visionOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(watchOS, unavailable)
    public func markdownRenderingMode(_ renderingMode: MarkdownRenderingMode) -> some View {
        fatalError("Rendering Mode unavailable")
    }
}

