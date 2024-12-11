import SwiftUI

struct MarkdownViewRoleKey: EnvironmentKey {
    static let defaultValue = MarkdownView.Role.normal
}

extension EnvironmentValues {
    var markdownViewRole: MarkdownView.Role {
        get { self[MarkdownViewRoleKey.self] }
        set { self[MarkdownViewRoleKey.self] = newValue }
    }
}

// MARK: - MarkdownView Role

extension View {
    ///  Configures the role of the markdown view.
    /// - Parameter role: A role to tell MarkdownView how to render its content.
    public func markdownViewRole(_ role: MarkdownView.Role) -> some View {
        #if os(watchOS)
        environment(\.markdownViewRole, .normal)
        #else
        environment(\.markdownViewRole, role)
        #endif
    }
}
