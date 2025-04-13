import SwiftUI

/// A type-erasure for type conforms to `ImageDisplayable`.
public struct AnyImageDisplayable: ImageDisplayable {
    public typealias ImageView = AnyView

    @ViewBuilder private let displayableClosure: (URL, String?) -> ImageView
    
    init<D: ImageDisplayable>(erasing imageDisplayable: D) {
        displayableClosure = { url, alt in
            imageDisplayable
                .makeImage(url: url, alt: alt)
                .erasedToAnyView()
        }
    }

    /// Creates a view that represents the body of the image
    public func makeImage(url: URL, alt: String?) -> ImageView {
        displayableClosure(url, alt)
    }
}
