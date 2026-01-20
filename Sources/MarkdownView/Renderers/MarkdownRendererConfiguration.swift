//
//  MarkdownRendererConfiguration.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import Foundation
import SwiftUI

public struct MarkdownRendererConfiguration: Equatable, Sendable {
    public internal(set) var preferredBaseURL: URL?
    public internal(set) var componentSpacing: CGFloat = 8
    public internal(set) var fonts: [MarkdownComponent: Font] = [
        .h1: Font.largeTitle,
        .h2: Font.title,
        .h3: Font.title2,
        .h4: Font.title3,
        .h5: Font.headline,
        .h6: Font.headline.weight(.regular),
        .body: Font.body,
        .codeBlock: Font.system(.callout, design: .monospaced),
        .blockQuote: Font.system(.body, design: .serif),
        .tableHeader: Font.headline,
        .tableBody: Font.body,
        .inlineMath: Font.body,
        .displayMath: Font.body,
    ]
    
    public internal(set) var math = MathRendering()
    public var rendersMath: Bool { math.isEnabled }
    
    public internal(set) var preferredTintColors: [MarkdownTintableComponent: Color] = [:]
    
    public internal(set) var list = MarkdownListConfiguration()
    
    public internal(set) var allowedImageRenderers: Set<String> = ["https", "http"]
    public internal(set) var allowedBlockDirectiveRenderers: Set<String> = []
    
    public init() {}
}

// MARK: - List

extension MarkdownRendererConfiguration {
    public struct MarkdownListConfiguration: Hashable, @unchecked Sendable {
        public internal(set) var leadingIndentation: CGFloat = 12
        public internal(set) var unorderedListMarker = AnyUnorderedListMarkerProtocol(.bullet)
        public internal(set) var orderedListMarker = AnyOrderedListMarkerProtocol(.increasingDigits)
        
        public init() {}
    }
}

// MARK: - Math Rendering

extension MarkdownRendererConfiguration {
    public struct MathRendering: Sendable, Hashable {
        public internal(set) var isEnabled: Bool = false
        public internal(set) var displayMathStorage: [UUID : String] = [:]
        
        mutating func setNeedsRendering(_ needRenderMath: Bool) {
            isEnabled = needRenderMath
        }
        
        mutating func appendDisplayMath(_ displayMath: some StringProtocol) -> UUID {
            let id = UUID()
            displayMathStorage[id] = String(displayMath)
            return id
        }
        
        public init() {}
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
