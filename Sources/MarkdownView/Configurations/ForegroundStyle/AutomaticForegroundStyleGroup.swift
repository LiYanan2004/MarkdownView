import SwiftUI

/// A foreground style group that resolves its content appearance automatically based on the current context.
///
/// Use ``HeadingStyleGroup/automatic`` to construct this type.
public struct AutomaticHeadingStyleGroup: HeadingStyleGroup { }

extension HeadingStyleGroup where Self == AutomaticHeadingStyleGroup {
    /// A foreground style group that resolves its content appearance automatically based on the current context.
    static public var automatic: AutomaticHeadingStyleGroup { .init() }
}
