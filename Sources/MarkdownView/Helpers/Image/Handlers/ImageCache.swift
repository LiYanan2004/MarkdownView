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
    ///   - image: the representation of the Image. `UIImage` OR `NSImage`
    ///   - url: The URL string of the Image
    func cacheImage(_ image: PlatformImage, url: URL) {
        guard !caches.contains(where: { $0.id == url }) else { return }
        
        caches.append(ImageCache(id: url, image: image))
    }
    
    /// Get image from Cache Controller.
    /// - Parameter url: Image URL
    /// - Returns: <Optional> Cached Image. Return `nil` if no cache linked to that URL.
    func image(from url: URL) -> PlatformImage? {
        caches.first(where: { $0.id == url })?.image
    }
    
    deinit {
        caches = []
    }
}

extension ImageCacheController: Equatable {
    static func == (lhs: ImageCacheController, rhs: ImageCacheController) -> Bool {
        true
    }
}
