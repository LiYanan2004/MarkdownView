import SwiftUI

/// A type that applies foreground styles to markdown headings.
public protocol HeadingStyleGroup {
    @_documentation(visibility: internal)
    associatedtype H1Style: ShapeStyle
    @_documentation(visibility: internal)
    associatedtype H2Style: ShapeStyle
    @_documentation(visibility: internal)
    associatedtype H3Style: ShapeStyle
    @_documentation(visibility: internal)
    associatedtype H4Style: ShapeStyle
    @_documentation(visibility: internal)
    associatedtype H5Style: ShapeStyle
    @_documentation(visibility: internal)
    associatedtype H6Style: ShapeStyle
    
    /// The style for displaying h1 text.
    var h1: H1Style { get }
    /// The style for displaying h2 text.
    var h2: H2Style { get }
    /// The style for displaying h3 text.
    var h3: H3Style { get }
    /// The style for displaying h4 text.
    var h4: H4Style { get }
    /// The style for displaying h5 text.
    var h5: H5Style { get }
    /// The style for displaying h6 text.
    var h6: H6Style { get }
    
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `CodeBlockStyle` instead.")
    @_documentation(visibility: internal)
    associatedtype CodeBlockStyle: ShapeStyle
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `BlockQuoteStyle` instead.")
    @_documentation(visibility: internal)
    associatedtype BlockQuoteStyle: ShapeStyle
    
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `CodeBlockStyle` instead.")
    @_documentation(visibility: internal)
    var codeBlock: CodeBlockStyle { get }
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `BlockQuoteStyle` instead.")
    @_documentation(visibility: internal)
    var blockQuote: BlockQuoteStyle { get }
    
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    @_documentation(visibility: internal)
    associatedtype TableHeaderStyle: ShapeStyle
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    @_documentation(visibility: internal)
    associatedtype TableBodyStyle: ShapeStyle
    
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    @_documentation(visibility: internal)
    var tableHeader: TableHeaderStyle { get }
    @available(*, deprecated, message: "This style will take no effect in current release and will be removed in the future. Implement a custom `MarkdownTableStyle` instead.")
    @_documentation(visibility: internal)
    var tableBody: TableBodyStyle { get }
}

extension HeadingStyleGroup {
    public var h1: some ShapeStyle { .foreground }
    public var h2: some ShapeStyle { .foreground }
    public var h3: some ShapeStyle { .foreground }
    public var h4: some ShapeStyle { .foreground }
    public var h5: some ShapeStyle { .foreground }
    public var h6: some ShapeStyle { .foreground }
    
    @_documentation(visibility: internal)
    public var codeBlock: some ShapeStyle { .foreground }
    @_documentation(visibility: internal)
    public var blockQuote: some ShapeStyle { .foreground }
    @_documentation(visibility: internal)
    public var tableHeader: some ShapeStyle { .foreground }
    @_documentation(visibility: internal)
    public var tableBody: some ShapeStyle { .foreground }
}

// MARK: - Environment Value

@MainActor
struct HeadingStyleGroupEnvironmentKey: @preconcurrency EnvironmentKey {
    static var defaultValue: AnyHeadingStyleGroup = .init(.automatic)
}

extension EnvironmentValues {
    package var headingStyleGroup: AnyHeadingStyleGroup {
        get { self[HeadingStyleGroupEnvironmentKey.self] }
        set { self[HeadingStyleGroupEnvironmentKey.self] = newValue }
    }
}
