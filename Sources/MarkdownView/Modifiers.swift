import SwiftUI

// MARK: - Content Loading
extension MarkdownView {
    /// Set the loading method.
    ///
    /// - Parameter lazyLoadingEnabled: A Boolean value that indicates whether to enable lazy loading.
    /// - Returns: `MarkdownView` with/without lazy loading functionality.
    ///
    /// If you set `lazyLoadingEnabled` to false, it may increase memory usage.
    public func lazyLoading(_ lazyLoadingEnabled: Bool) -> MarkdownView {
        var result = self
        result.lazyLoad = lazyLoadingEnabled
        
        return result
    }
}

// MARK: - Image Handlers
extension MarkdownView {
    /// Set your custom Image Handler
    ///
    /// - parameters
    ///     - handler: the handler you have created to handle image loading and displaying.
    ///     - urlScheme: specify which kind of image will use your own handler.
    /// - Returns: `MarkdownView` with custom image loading behavior.
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    public func imageHandler(
        _ handler: MarkdownImageHandler, forURLScheme urlScheme: String
    ) -> MarkdownView {
        let result = self
        result.imageHandlerConfiguration.addHandler(handler, forURLScheme: urlScheme)
        
        return result
    }
}

// MARK: - Custom Directive Blocks
extension MarkdownView {
    /// Set your custom Directive Block Handler
    ///
    /// - parameter handler: the handler you have created to handle block displaying.
    /// - parameter name: specify which kind of Directive Block will use your own handler.
    /// - Returns: `MarkdownView` with custom directive block loading behavior.
    ///
    /// You can set this handler multiple times if you have multiple handlers.
    public func directiveBlockHandler(
        _ handler: MarkdownDirectiveBlockHandler, for name: String
    ) -> MarkdownView {
        let result = self
        result.directiveBlockConfiguration.addHandler(handler, for: name)
        
        return result
    }
    
    /// Disable the default `@Background(background: _, textColor: _)` Directive Block.
    ///
    /// - Returns: `MarkdownView` without any Directive Block Handler.
    /// 
    /// If your Directive Block's name conflicts with the default one, you can disable the default one.
    @available(*, deprecated, message: "The @background handler will not be enabled by default.")
    public func disableDefaultDirectiveBlockHandler() -> MarkdownView {
        let result = self
        result.directiveBlockConfiguration.directiveBlockHandlers = [:]
        
        return result
    }
}

// MARK: - Code Block Theme
extension MarkdownView {
    /// Customize the theme of the Code Block
    /// - Parameter configuration: Theme configuration of the Code Block, see ``CodeBlockThemeConfiguration``.
    /// - Returns: `MarkdownView` with custom Code Block theme.
    public func codeBlockThemeConfiguration(
        using configuration: CodeBlockThemeConfiguration
    ) -> MarkdownView {
        var result = self
        result.codeBlockThemeConfiguration = configuration
        
        return result
    }
}
