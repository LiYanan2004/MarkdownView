import SwiftUI
import MarkdownRenderingEssentials

/// A type that applies font group to all MarkdownViews within a view hierarchy.
///
/// To configure the current font group for a view hierarchy, use ``MarkdownView/MarkdownView/fontGroup(_:)`` modifier. Specify a font group that conforms to MarkdownFontGroup when creating a MarkdownView.
public protocol MarkdownFontGroup {
    // Headings
    var h1: any CustomCTFontConvertible { get }
    var h2: any CustomCTFontConvertible { get }
    var h3: any CustomCTFontConvertible { get }
    var h4: any CustomCTFontConvertible { get }
    var h5: any CustomCTFontConvertible { get }
    var h6: any CustomCTFontConvertible { get }
    
    // Normal text
    var body: any CustomCTFontConvertible { get }
    
    // Blocks
    var codeBlock: any CustomCTFontConvertible { get }
    var blockQuote: any CustomCTFontConvertible { get }
    
    // Tables
    var tableHeader: any CustomCTFontConvertible { get }
    var tableBody: any CustomCTFontConvertible { get }
    
    // Math
    var inlineMath: any CustomCTFontConvertible { get }
    var displayMath: any CustomCTFontConvertible { get }
}

extension MarkdownFontGroup {
    public var h1: any CustomCTFontConvertible {
        #if os(tvOS)
        PlatformFont.preferredFont(forTextStyle: .title1)
        #else
        PlatformFont.preferredFont(forTextStyle: .largeTitle)
        #endif
    }
    public var h2: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .title1) }
    public var h3: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .title2) }
    public var h4: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .title3) }
    public var h5: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .headline) }
    public var h6: any CustomCTFontConvertible {
        PlatformFont.systemFont(
            ofSize: PlatformFont.preferredFont(forTextStyle: .headline).pointSize,
            weight: .regular
        )
    }
    
    // Normal text
    public var body: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .body) }
    
    // Blocks
    public var codeBlock: any CustomCTFontConvertible {
        PlatformFont.monospacedSystemFont(
            ofSize: PlatformFont.preferredFont(forTextStyle: .callout).pointSize,
            weight: .regular
        )
    }
    public var blockQuote: any CustomCTFontConvertible {
        let bodyFont = PlatformFont.preferredFont(forTextStyle: .body)
        guard let serifFontDescriptor = bodyFont.fontDescriptor.withDesign(.serif) else {
            return bodyFont
        }
        #if canImport(UIKit)
        return PlatformFont(descriptor: serifFontDescriptor, size: bodyFont.pointSize)
        #else
        return PlatformFont(descriptor: serifFontDescriptor, size: bodyFont.pointSize) ?? bodyFont
        #endif
    }
    
    // Tables
    public var tableHeader: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .headline)
    }
    public var tableBody: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .body)
    }
    
    // Math
    public var inlineMath: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .body) }
    public var displayMath: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .body)
    }
}

// MARK: - Environment Values

struct MarkdownFontGroupEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyMarkdownFontGroup = .init(.automatic)
}

extension EnvironmentValues {
    package var markdownFontGroup: AnyMarkdownFontGroup {
        get { self[MarkdownFontGroupEnvironmentKey.self] }
        set { self[MarkdownFontGroupEnvironmentKey.self] = newValue }
    }
}
