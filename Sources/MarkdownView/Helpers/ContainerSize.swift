import SwiftUI

struct ContainerMeasurement: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ContainerSize: EnvironmentKey {
    static var defaultValue = CGSize.zero
}

extension EnvironmentValues {
    var containerSize: CGSize {
        get { self[ContainerSize.self] }
        set { self[ContainerSize.self] = newValue }
    }
}
