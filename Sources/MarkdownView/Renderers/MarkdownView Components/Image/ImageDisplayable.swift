import SwiftUI

/// A type that  renders images.
public protocol ImageDisplayable {
    associatedtype ImageView: View
    
    /// Creates a view that represents the image.
    @ViewBuilder func makeImage(url: URL, alt: String?) -> ImageView
}
