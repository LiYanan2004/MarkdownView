import SwiftUI

struct NetworkImage: View {
    var url: URL
    var alt: String?
    @State private var image: Image?
    @State private var imageSize = CGSize.zero
    @State private var localizedError: String?
    @State private var svg: SVGInfo?
    @Environment(\.displayScale) private var scale
    
    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: max(imageSize.width, imageSize.height))
            } else if let svg {
                SVGView(html: svg.html)
                    .disabled(true) // Disable bounces
                    .frame(width: svg.size.width, height: svg.size.height)
            } else if let localizedError {
                Text(localizedError + "\n" + "Tap to reload.")
                    .textSelection(.disabled)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .containerShape(Rectangle())
                    .onTapGesture(perform: reloadImage)
            } else {
                ProgressView()
                    .controlSize(.small)
                    .frame(maxWidth: imageSize == .zero ? .infinity : imageSize.width)
            }

            if let alt {
                Text(alt)
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }
        }
        .overlay {
            GeometryReader { proxy in
                Color.black.opacity(0.001)
                    .allowsHitTesting(false)
                    .task(id: url) {
                        do {
                            try await loadContent(size: proxy.size)
                        } catch {
                            localizedError = error.localizedDescription
                            print(error.localizedDescription)
                        }
                    }
            }
        }
    }
    
    private func reloadImage() {
        image = nil
        localizedError = nil
        imageSize = CGSize.zero
    }
    
    private func loadContent(size: CGSize) async throws {
        let data = try await loadResource()
        
        do {
            // First, we look at if we can load data as SVG content.
            #if !os(watchOS)
            try await loadAsSVG(data: data)
            #else
            // For watchOS, throw an error.
            throw ImageError.notSVG
            #endif
        } catch {
            // If the content is not SVG, then load it as Native Image.
            #if os(macOS)
            if let image = NSImage(data: data) {
                self.image = Image(nsImage: image)
                self.imageSize = image.size
                return
            }
            #elseif os(iOS) || os(tvOS)
            if let image = UIImage(data: data) {
                try await prepareThumbnailAndDisplay(for: image, size: size)
                self.imageSize = image.size
                return
            }
            #endif
        }
    }
}

// MARK: - Helper
extension NetworkImage {
    private func loadResource() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    #if os(iOS) || os(tvOS)
    private func prepareThumbnailAndDisplay(for image: UIImage, size: CGSize) async throws {
        let thumbnailSize = thumbnailSize(for: image, byReferencing: size)
        if let thumbnail = await image.byPreparingThumbnail(ofSize: thumbnailSize) {
            self.image = Image(uiImage: thumbnail)
        } else {
            throw ImageError.thumbnailError
        }
    }
    
    private func thumbnailSize(for image: UIImage, byReferencing size: CGSize) -> CGSize {
        let aspectRatio = image.size.width / image.size.height
        let thumbnailHeight = size.width / aspectRatio
        
        return CGSize(width: size.width * scale, height: thumbnailHeight * scale)
    }
    #endif
    
    func loadAsSVG(data: Data) async throws {
        guard let svg = String(data: data, encoding: .utf8) else { throw ImageError.notSVG }
        guard svg.starts(with: "<svg") else {
            throw ImageError.notSVG
        }
        
        guard let widthRegex = try? NSRegularExpression(pattern: "width[ ]?=[ ]?\"([0-9]+)\"", options: NSRegularExpression.Options.caseInsensitive),
              let widthMatch = widthRegex.firstMatch(in: svg, options: [], range: NSRange(location: 0, length: svg.count)),
              let widthRange = Range(widthMatch.range(at: 1), in: svg),
              let width = Double(String(svg[widthRange]))
        else { throw ImageError.svgMissingMeta }
        
        guard let heightRegex = try? NSRegularExpression(pattern: "height[ ]?=[ ]?\"([0-9]+)\"", options: NSRegularExpression.Options.caseInsensitive),
              let heightMatch = heightRegex.firstMatch(in: svg, options: [], range: NSRange(location: 0, length: svg.count)),
              let heightRange = Range(heightMatch.range(at: 1), in: svg),
              let height = Double(String(svg[heightRange]))
        else { throw ImageError.svgMissingMeta }
        
        let html = "<body style='margin:0;padding:0;background-color:transparent;'>\(svg)</body>"
        self.svg = SVGInfo(html: html, size: CGSize(width: width, height: height))
    }
}

// MARK: - Errors
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

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension Image {
    init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}

fileprivate struct SVGInfo {
    var html: String
    var size: CGSize
}
