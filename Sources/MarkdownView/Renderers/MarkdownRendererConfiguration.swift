//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

struct MarkdownRendererConfiguration: Equatable, KeyPathModifying, Sendable {
    var preferredBaseURL: URL?
    var componentSpacing: CGFloat = 8
    
    var math = MathRendering()
    var rendersMath: Bool { math.isEnabled }
    
    var preferredTintColors: [MarkdownTintableComponent: Color] = [:]
    
    var list = MarkdownListConfiguration()
    
    var allowedImageRenderers: Set<String> = ["https", "http"]
    var allowedBlockDirectiveRenderers: Set<String> = []
}

// MARK: - List

extension MarkdownRendererConfiguration {
    struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
        var leadingIndentation: CGFloat = 12
        var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
        var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
    }
}

// MARK: - Math Rendering

extension MarkdownRendererConfiguration {
    struct MathRendering: Sendable, Hashable {
        var isEnabled: Bool = false
        var displayMathStorage: [UUID : String] = [:]
        
        mutating func setNeedsRendering(_ needRenderMath: Bool) {
            isEnabled = needRenderMath
        }
        
        mutating func appendDisplayMath(_ displayMath: some StringProtocol) -> UUID {
            let id = UUID()
            displayMathStorage[id] = String(displayMath)
            return id
        }
    }
}

// MARK: - SwiftUI Environment

struct MarkdownRendererConfigurationKey: EnvironmentKey {
    static let defaultValue: MarkdownRendererConfiguration = .init()
}

extension EnvironmentValues {
    var markdownRendererConfiguration: MarkdownRendererConfiguration {
        get { self[MarkdownRendererConfigurationKey.self] }
        set { self[MarkdownRendererConfigurationKey.self] = newValue }
    }
}
