import SwiftUI

/// A foreground style group that resolves its content appearance automatically based on the current context.
///
/// Use ``HeadingForegroundStyleGroup/automatic`` to construct this type.
public struct AutomaticHeadingForegroundStyleGroup: HeadingStyleGroup { }

extension HeadingStyleGroup where Self == AutomaticHeadingForegroundStyleGroup {
    /// A foreground style group that resolves its content appearance automatically based on the current context.
    static public var automatic: AutomaticHeadingForegroundStyleGroup { .init() }
}
