/// Deprecated modifiers
extension MarkdownView {
    /// Sets the loading method.
    ///
    /// - Parameter lazyLoadingEnabled: A Boolean value that indicates whether to enable lazy loading.
    /// - Returns: `MarkdownView` with/without lazy loading functionality.
    ///
    /// If you set `lazyLoadingEnabled` to false, it may increase memory usage.
    @available(*, deprecated, message: "If you still have a performance issue, please post an issue.")
    public func lazyLoading(_ lazyLoadingEnabled: Bool) -> MarkdownView {
        let result = self
        /* result.lazyLoad = lazyLoadingEnabled */
        return result
    }
    
    /// Sets your custom Image Handler.
    ///
    /// - parameters
    ///     - handler: the handler you have created to handle image loading and displaying.
    ///     - urlScheme: specify which kind of image will use your own handler.
    /// - Returns: `MarkdownView` with custom image loading behavior.
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    @available(*, unavailable, message: "You can not use this modifier to add handlers any more.\nCreate your own handler that conforms to ImageDisplayable and use \"imageHandler(_:forURLScheme:)\" instead.")
    public func imageHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        /*result.imageHandlerConfiguration.addHandler(handler, forURLScheme: urlScheme)*/
        
        return result
    }
    
    /// Sets your custom Directive Block Handler.
    ///
    /// - parameter handler: the handler you have created to handle block displaying.
    /// - parameter name: specify which kind of Directive Block will use your own handler.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    @available(*, unavailable, message: "Create your own handler that conforms to BlockDirectiveDisplayable and use \"blockDirectiveHandler(_:for:)\" instead.")
    public func directiveBlockHandler(
        _ handler: MarkdownDirectiveBlockHandler, for name: String
    ) -> MarkdownView {
        let result = self
        /*result.directiveBlockConfiguration.addHandler(handler, for: name)*/
        
        return result
    }
    
    /// Sets the theme of the Code Blocks.
    ///
    /// - Parameter configuration: Theme configuration of the Code Block, see ``CodeBlockThemeConfiguration``.
    /// - Returns: `MarkdownView` with custom Code Block theme.
    @available(*, deprecated, renamed: "codeBlockTheme")
    public func codeBlockThemeConfiguration(
        using configuration: CodeBlockThemeConfiguration
    ) -> MarkdownView {
        var result = self
        result.codeBlockTheme = CodeBlockTheme(lightModeThemeName: configuration.lightModeThemeName, darkModeThemeName: configuration.darkModeThemeName)
        
        return result
    }
}
