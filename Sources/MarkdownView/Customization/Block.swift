import SwiftUI


struct ComponentSpacingEnvironmentKey: EnvironmentKey {
    static var defaultValue: CGFloat = 8
}

extension EnvironmentValues {
    var componentSpacing: CGFloat {
        get { self[ComponentSpacingEnvironmentKey.self] }
        set { self[ComponentSpacingEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func componentSpacing(_ spacing: CGFloat) -> some View {
        self.environment(\.componentSpacing, spacing)
    }
}


struct ListIndentEnvironmentKey: EnvironmentKey {
    static var defaultValue: CGFloat = 12
}

extension EnvironmentValues {
    var listIndent: CGFloat {
        get { self[ListIndentEnvironmentKey.self] }
        set { self[ListIndentEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func listIndent(_ indent: CGFloat) -> some View {
        self.environment(\.listIndent, indent)
    }
}


struct UnorderedListBulletEnvironmentKey: EnvironmentKey {
    static var defaultValue: String = "•"
}

extension EnvironmentValues {
    var unorderedListBullet: String {
        get { self[UnorderedListBulletEnvironmentKey.self] }
        set { self[UnorderedListBulletEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func unorderedListBullet(_ bullet: String) -> some View {
        self.environment(\.unorderedListBullet, bullet)
    }
}


struct UnorderedListBulletFontEnvironmentKey: EnvironmentKey {
    static var defaultValue: Font = .title2.weight(.black)
}

extension EnvironmentValues {
    var unorderedListBulletFont: Font {
        get { self[UnorderedListBulletFontEnvironmentKey.self] }
        set { self[UnorderedListBulletFontEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func unorderedListBullet(_ font: Font) -> some View {
        self.environment(\.unorderedListBulletFont, font)
    }
}
