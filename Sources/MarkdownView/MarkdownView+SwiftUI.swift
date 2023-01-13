import SwiftUI

// MARK: - Content Loading
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
}

// MARK: - Image Handlers
extension MarkdownView {
    /// Sets your custom Image Handler.
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
    /// Sets your custom Directive Block Handler.
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
    
    /// Disables the default `@Background(background: _, textColor: _)` Directive Block.
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
    /// Sets the theme of the Code Blocks.
    /// 
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

// MARK: - MarkdownView Role
extension MarkdownView {
    ///  Configures the role of the markdown text.
    /// - Parameter role: A role to tell MarkdownView how to render its content.
    /// - Returns: A rendered MarkdownView using the role you specified.
    public func markdownViewRole(_ role: MarkdownViewRole) -> MarkdownView {
        var result = self
        result.role = role
        
        return result
    }
    
    public enum MarkdownViewRole {
        /// The normal role.
        ///
        /// A role that makes the view take the space it needs, like a normal SwiftUI View.
        case normal
        /// The editor role.
        ///
        /// A role that makes the view take the maximum space
        /// and align its content in the top-leading, just like an editor.
        ///
        /// A Markdown Editor typically use this mode to provide a Live Preview.
        case editor
    }
}
