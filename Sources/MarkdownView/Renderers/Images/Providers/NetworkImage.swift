import SwiftUI

struct NetworkImage: View {
    var url: URL
    var alt: String?
    @State private var image: Image?
    @State private var imageSize = CGSize.zero
    @State private var svg: SVG?
    @State private var isSupported = true
    @Environment(\.displayScale) private var scale
    
    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: max(imageSize.width, imageSize.height))
                    .task { await cacheFetchedImage(image) }
            } else if let svg {
                #if os(iOS) || os(macOS)
                SVGView(svg: svg)
                    .task { await cacheFetchedSVG(svg) }
                #endif
            } else if !isSupported {
                ImagePlaceholder()
            } else {
                ProgressView()
                    #if os(macOS)
                    .controlSize(.small)
                    #endif
                    .frame(maxWidth: 50, alignment: .leading)
            }
            
            let isLoaded = image != nil || svg != nil
            if isLoaded, let alt {
                Text(alt)
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
        .onChange(of: url, initial: true) {
            Task.detached {
                let loadedFromCache = Task { @MainActor in
                    await loadFromCache()
                }
                guard await !loadedFromCache.value else { return }
                
                do {
                    try await loadContent()
                } catch where error is ImageError {
                    await MainActor.run {
                        isSupported = false
                    }
                    print(error.localizedDescription)
                } catch { }
            }
        }
        #if os(iOS) || os(macOS)
        .onTapGesture(perform: reloadImage)
        #endif
    }
    
    private func reloadImage() {
        guard !isSupported else { return }
        isSupported = true
        image = nil
        imageSize = CGSize.zero
    }
    
    private func loadFromCache() async -> Bool {
        let retrievedFromCache = CacheStorage.shared.withCacheIfAvailable(url) { cache in
            if let imageCache = cache as? FetchedImage {
                Task { @MainActor in
                    self.imageSize = imageCache.size
                    self.image = imageCache.image
                }
                return true
            } else if let svgCache = cache as? FetchedSVG {
                Task { @MainActor in
                    self.svg = svgCache.svg
                }
                return true
            }
            return false
        }
        
        if let retrievedFromCache, retrievedFromCache {
            return true
        }
        return false
    }
    
    nonisolated private func loadContent() async throws {
        let data = try await loadResource()
        
        do {
            // First, we look at if we can load data as SVG content.
            try await loadAsSVG(data: data)
        } catch {
            // If the content is not SVG, then try to load it as Native Image.
            #if os(macOS)
            if let image = NSImage(data: data) {
                await MainActor.run {
                    self.image = Image(platformImage: image)
                    self.imageSize = image.size
                }
            } else {
                throw ImageError.formatError
            }
            #else
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = Image(platformImage: image)
                    self.imageSize = image.size
                }
            } else {
                throw ImageError.formatError
            }
            #endif
        }
    }
}

// MARK: - Auxiliary

extension NetworkImage {
    private func loadResource() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func loadAsSVG(data: Data) async throws {
        guard let text = String(data: data, encoding: .utf8),
              let svg = SVG(from: text) else { throw ImageError.notSVG }
        
        #if os(watchOS) || os(tvOS)
        // This is an SVG content,
        // but this platform doesn't support WKWebView.
        isSupported = false
        #else
        self.svg = svg
        #endif
    }
}


// MARK: - Content Caching

extension NetworkImage {
    private func cacheFetchedImage(_ image: Image) async {
        let fetchedImage = FetchedImage(
            url: url,
            image: image,
            size: imageSize
        )
        CacheStorage.shared.addCache(fetchedImage)
    }
    
    private func cacheFetchedSVG(_ svg: SVG) async {
        let fetchedSVG = FetchedSVG(url: url, svg: svg)
        CacheStorage.shared.addCache(fetchedSVG)
    }
}

// MARK: - Error Handling

extension NetworkImage {
    private enum ImageError: String, LocalizedError, CustomStringConvertible {
        case thumbnailError = "Failed to prepare a thumbnail"
        case resourceError = "Fetched Data is invalid"
        case formatError = "Unsupported Image format"
        case notSVG = "The content is not SVG"
        case svgMissingMeta = "Missing width / height information in SVG content"
        
        var errorDescription: LocalizedStringKey? {
            switch self {
            case .thumbnailError: return "Failed to prepare a thumbnail"
            case .resourceError: return "Fetched Data is invalid"
            case .formatError: return "Unsupported Image format"
            case .notSVG: return "The content is not SVG or device not support rendering SVG"
            case .svgMissingMeta: return "Missing width / height information"
            }
        }
        
        var description: String { errorDescription! }
    }
}
