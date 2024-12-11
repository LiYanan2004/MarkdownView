import SwiftUI

public protocol ImageDisplayable {
    associatedtype ImageView: View
    
    /// Make the Image View.
    @ViewBuilder func makeImage(url: URL, alt: String?) -> ImageView
}

// MARK: - Built-in providers





