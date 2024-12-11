import SwiftUI

extension View {
    /// Adds your custom block directive provider.
    ///
    /// - parameters:
    ///     - provider: The provider you have created to handle block displaying.
    ///     - name: The name of the  block directive.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this provider multiple times if you have multiple providers.
    public func blockDirectiveProvider(
        _ provider: some BlockDirectiveDisplayable, for name: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.blockDirectiveRenderer.addProvider(provider, for: name)
        }
    }
    
    /// Add your own providers to render images.
    ///
    /// - parameters
    ///     - provider: The provider you created to handle image loading and displaying.
    ///     - urlScheme: A scheme for the renderer to determine when to use the provider.
    /// - Returns: View that able to render images with specific schemes.
    ///
    /// You can set the provider multiple times if you want to add multiple schemes.
    public func imageProvider(
        _ provider: some ImageDisplayable, forURLScheme urlScheme: String
    ) -> some View {
        transformEnvironment(\.markdownRendererConfiguration) { configuration in
            configuration.imageRenderer.addProvider(provider, forURLScheme: urlScheme)
        }
    }
    
    /// Apply a font group to MarkdownView.
    ///
    /// Customize fonts for multiple types of text.
    ///
    /// - Parameter fontGroup: A font set to apply to the MarkdownView.
    public func fontGroup(_ fontGroup: some MarkdownFontGroup) -> some View {
        environment(\.markdownRendererConfiguration.fontGroup, .init(fontGroup))
    }
    
    /// Sets the font for the specific component in MarkdownView.
    /// - Parameters:
    ///   - font: The font to apply to these components.
    ///   - type: The type of components to apply the font.
    public func font(_ font: Font, for type: MarkdownTextType) -> some View {
        transformEnvironment(\.markdownRendererConfiguration.fontGroup) { fontGroup in
            switch type {
            case .h1: fontGroup._h1 = font
            case .h2: fontGroup._h2 = font
            case .h3: fontGroup._h3 = font
            case .h4: fontGroup._h4 = font
            case .h5: fontGroup._h5 = font
            case .h6: fontGroup._h6 = font
            case .body: fontGroup._body = font
            case .blockQuote: fontGroup._blockQuote = font
            case .codeBlock: fontGroup._codeBlock = font
            case .tableBody: fontGroup._tableBody = font
            case .tableHeader: fontGroup._tableHeader = font
            }
        }
    }
    
    /// Apply a foreground style group to MarkdownView.
    ///
    /// This is useful when you want to completely customize foreground styles.
    ///
    /// - Parameter foregroundStyleGroup: A style set to apply to the MarkdownView.
    @ViewBuilder
    public func foregroundStyleGroup(_ foregroundStyleGroup: some MarkdownForegroundStyleGroup) -> some View {
        environment(\.markdownRendererConfiguration.foregroundStyleGroup, .init(foregroundStyleGroup))
    }
    
    /// Sets foreground style for the specific component in MarkdownView.
    ///
    /// - Parameters:
    ///   - style: The style to apply to this type of components.
    ///   - component: The type of components to apply the foreground style.
    @ViewBuilder
    public func foregroundStyle(_ style: some ShapeStyle, for component: ColorableComponent) -> some View {
        transformEnvironment(\.markdownRendererConfiguration.foregroundStyleGroup) { foregroundStyleGroup in
            let erasedShapeStyle = AnyShapeStyle(style)
            switch component {
            case .h1: foregroundStyleGroup._h1 = erasedShapeStyle
            case .h2: foregroundStyleGroup._h2 = erasedShapeStyle
            case .h3: foregroundStyleGroup._h3 = erasedShapeStyle
            case .h4: foregroundStyleGroup._h4 = erasedShapeStyle
            case .h5: foregroundStyleGroup._h5 = erasedShapeStyle
            case .h6: foregroundStyleGroup._h6 = erasedShapeStyle
            case .blockQuote: foregroundStyleGroup._blockQuote = erasedShapeStyle
            case .codeBlock: foregroundStyleGroup._codeBlock = erasedShapeStyle
            case .tableBody: foregroundStyleGroup._tableBody = erasedShapeStyle
            case .tableHeader: foregroundStyleGroup._tableHeader = erasedShapeStyle
            }
        }
    }
    
    /// Sets the theme of the code highlighter.
    ///
    /// For more information of available themes, see ``CodeHighlighterTheme``.
    ///
    /// - Parameter theme: The theme for highlighter.
    ///
    /// - note: Code highlighting is not available on watchOS.
    public func codeHighlighterTheme(_ theme: CodeHighlighterTheme) -> some View {
        environment(\.markdownRendererConfiguration.codeBlockTheme, theme)
    }
    
    ///  Configures the role of the markdown view.
    /// - Parameter role: A role to tell MarkdownView how to render its content.
    public func markdownViewRole(_ role: MarkdownView.Role) -> some View {
        #if os(watchOS)
        environment(\.markdownRendererConfiguration.role, .normal)
        #else
        environment(\.markdownRendererConfiguration.role, role)
        #endif
    }
    
    public func markdownListIndent(_ indent: CGFloat) -> some View {
        self.environment(\.markdownRendererConfiguration.listConfiguration.listIndent, indent)
    }
    
    public func markdownUnorderedListBullet(_ bullet: String) -> some View {
        self.environment(\.markdownRendererConfiguration.listConfiguration.unorderedListBullet, bullet)
    }
    
    public func markdownComponentSpacing(_ spacing: CGFloat) -> some View {
        self.environment(\.markdownRendererConfiguration.componentSpacing, spacing)
    }
    
    /// Sets the tint color for specific MarkdownView component.
    ///
    /// - Parameters:
    ///   - tint: The tint color to apply.
    ///   - component: The tintable component to apply the tint color.
    @ViewBuilder
    public func tint(_ tint: Color, for component: TintableComponent) -> some View {
        switch component {
        case .blockQuote:
            environment(\.markdownRendererConfiguration.blockQuoteTintColor, tint)
        case .inlineCodeBlock:
            environment(\.markdownRendererConfiguration.inlineCodeTintColor, tint)
        }
    }
    
    /// MarkdownView rendering mode.
    ///
    /// - Parameter renderingMode: Markdown rendering mode.
    public func markdownRenderingMode(_ renderingMode: MarkdownRenderingMode) -> some View {
        environment(\.markdownRenderingMode, renderingMode)
    }
}
