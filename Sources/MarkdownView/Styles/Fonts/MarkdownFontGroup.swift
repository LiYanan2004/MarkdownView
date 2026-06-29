import SwiftUI

/// A type that provides fonts for markdown components in a view hierarchy.
///
/// Use a font group when the same typography should apply to many MarkdownView or MarkdownText instances. A custom group can override only the components that differ from the defaults.
///
/// Prefer `PlatformFont` or `CTFont` when the fonts also need to render in MarkdownText on older operating systems. SwiftUI `Font` resolves to a `CTFont` only on operating systems that support SwiftUI font resolution.
///
/// The following example keeps the default heading fonts and customizes body and code block fonts.
///
/// ```swift
/// struct ArticleMarkdownFontGroup: MarkdownFontGroup {
///     var body: any CustomCTFontConvertible {
///         PlatformFont.preferredFont(forTextStyle: .body)
///     }
///
///     var codeBlock: any CustomCTFontConvertible {
///         PlatformFont.monospacedSystemFont(
///             ofSize: PlatformFont.preferredFont(forTextStyle: .callout).pointSize,
///             weight: .regular
///         )
///     }
/// }
///
/// MarkdownView(markdown)
///     .markdownFontGroup(ArticleMarkdownFontGroup())
/// ```
public protocol MarkdownFontGroup {
    /// The font used for level-one headings.
    var h1: any CustomCTFontConvertible { get }

    /// The font used for level-two headings.
    var h2: any CustomCTFontConvertible { get }

    /// The font used for level-three headings.
    var h3: any CustomCTFontConvertible { get }

    /// The font used for level-four headings.
    var h4: any CustomCTFontConvertible { get }

    /// The font used for level-five headings.
    var h5: any CustomCTFontConvertible { get }

    /// The font used for level-six headings.
    var h6: any CustomCTFontConvertible { get }
    
    /// The font used for body text.
    var body: any CustomCTFontConvertible { get }
    
    /// The font used for fenced code blocks.
    var codeBlock: any CustomCTFontConvertible { get }

    /// The font used for block quotes.
    var blockQuote: any CustomCTFontConvertible { get }
    
    /// The font used for table header cells.
    var tableHeader: any CustomCTFontConvertible { get }

    /// The font used for table body cells.
    var tableBody: any CustomCTFontConvertible { get }
    
    /// The font used for inline math.
    var inlineMath: any CustomCTFontConvertible { get }

    /// The font used for display math.
    var displayMath: any CustomCTFontConvertible { get }
}

extension MarkdownFontGroup {
    /// The default font used for level-one headings.
    public var h1: any CustomCTFontConvertible {
        #if os(tvOS)
        PlatformFont.preferredFont(forTextStyle: .title1)
        #else
        PlatformFont.preferredFont(forTextStyle: .largeTitle)
        #endif
    }

    /// The default font used for level-two headings.
    public var h2: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .title1) }

    /// The default font used for level-three headings.
    public var h3: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .title2) }

    /// The default font used for level-four headings.
    public var h4: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .title3) }

    /// The default font used for level-five headings.
    public var h5: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .headline) }

    /// The default font used for level-six headings.
    public var h6: any CustomCTFontConvertible {
        PlatformFont.systemFont(
            ofSize: PlatformFont.preferredFont(forTextStyle: .headline).pointSize,
            weight: .regular
        )
    }
    
    /// The default font used for body text.
    public var body: any CustomCTFontConvertible { PlatformFont.preferredFont(forTextStyle: .body) }
    
    /// The default font used for fenced code blocks.
    public var codeBlock: any CustomCTFontConvertible {
        PlatformFont.monospacedSystemFont(
            ofSize: PlatformFont.preferredFont(forTextStyle: .callout).pointSize,
            weight: .regular
        )
    }

    /// The default font used for block quotes.
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
    
    /// The default font used for table header cells.
    public var tableHeader: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .headline)
    }

    /// The default font used for table body cells.
    public var tableBody: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .body)
    }
    
    /// The default font used for inline math.
    public var inlineMath: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .body) }

    /// The default font used for display math.
    public var displayMath: any CustomCTFontConvertible {
        PlatformFont.preferredFont(forTextStyle: .body)
    }
}

// MARK: - Environment Values

struct MarkdownFontGroupEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyMarkdownFontGroup = .init(.automatic)
}

extension EnvironmentValues {
    var markdownFontGroup: AnyMarkdownFontGroup {
        get { self[MarkdownFontGroupEnvironmentKey.self] }
        set { self[MarkdownFontGroupEnvironmentKey.self] = newValue }
    }
}
