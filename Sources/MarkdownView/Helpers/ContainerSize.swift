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

struct SizeReader: ViewModifier {
    @State private var containerSize = CGSize.zero
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ContainerMeasurement.self, value: proxy.size)
                }
            }
            .onPreferenceChange(ContainerMeasurement.self) {
                containerSize = $0
            }
            .environment(\.containerSize, containerSize)
    }
}

extension View {
    func readViewSize() -> some View {
        modifier(SizeReader())
    }
}
