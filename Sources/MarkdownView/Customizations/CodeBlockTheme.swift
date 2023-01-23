/// The configuration for code blocks.
///
/// - note: For more information, Check out [raspu/Highlightr](https://github.com/raspu/Highlightr) .
public struct CodeBlockTheme: Equatable {
    /// The theme name in Light Mode.
    var lightModeThemeName: String
    
    /// The theme name in Dark Mode.
    var darkModeThemeName: String
    
    /// Creates a single theme for the Code Block.
    ///
    /// - Parameter themeName: the name of the theme to use in both Light Mode and Dark Mode.
    ///
    /// - warning: You should test the visibility of the code in Light Mode and Dark Mode first.
    public init(themeName: String) {
        lightModeThemeName = themeName
        darkModeThemeName = themeName
    }
    
    /// Creates a combination of two themes that will perfectly adapt both Light Mode and Dark Mode.
    ///
    /// - Parameters:
    ///   - lightModeThemeName: the name of the theme to use in Light Mode.
    ///   - darkModeThemeName: the name of the theme to use in Dark Mode.
    ///
    ///  If you want to use the same theme on both Dark Mode and Light Mode,
    ///  you should use ``init(themeName:)``.
    public init(lightModeThemeName: String, darkModeThemeName: String) {
        self.lightModeThemeName = lightModeThemeName
        self.darkModeThemeName = darkModeThemeName
    }
}
