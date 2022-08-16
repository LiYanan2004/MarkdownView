import SwiftUI

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

/// A model that stores `URL` and loaded `Image`
struct ImageCache: Identifiable, Equatable {
    /// The URL of the Image
    var id: URL
    
    /// The stored Image for caching
    var image: PlatformImage
}

/// Stores all the image Caches
class ImageCacheController: ObservableObject {
    
    /// All Caches are stored here where you can read from
    var caches: [ImageCache] = []
    
    /// Add the loaded `Image` and `URL`(as the identifier) to the Caches
    /// - Parameters:
    ///   - url: The URL string of the Image
    ///   - image: the representation of the Image. `UIImage` OR `NSImage`
    func addImageCache(url: URL, image: PlatformImage) {
        guard !caches.contains(where: { $0.id == url }) else { return }
        
        caches.append(ImageCache(id: url, image: image))
    }
    
    deinit {
        caches = []
    }
}
