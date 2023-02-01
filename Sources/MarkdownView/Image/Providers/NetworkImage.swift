import SwiftUI

struct NetworkImage: View {
    var url: URL
    var alt: String?
    @State private var image: Image?
    @State private var imageSize = CGSize.zero
    @State private var svg: SVGInfo?
    @State private var isSupported = true
    @Environment(\.displayScale) private var scale
    
    var body: some View {
        VStack {
            if let image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: max(imageSize.width, imageSize.height))
            } else if let svg {
                #if os(iOS) || os(macOS)
                SVGView(html: svg.html)
                    .disabled(true) // Disable bounces
                    .frame(width: svg.size.width, height: svg.size.height)
                #endif
            } else if !isSupported {
                ImagePlaceholder()
            } else {
                ProgressView()
                    #if os(macOS)
                    .controlSize(.small)
                    #endif
                    .frame(maxWidth: 50)
                    .task(id: url) {
                        do {
                            try await loadContent()
                        } catch {
                            isSupported = false
                            print(error.localizedDescription)
                        }
                    }
            }
            
            let isLoaded = imageSize != .zero || !isSupported
            if isLoaded, let alt {
                Text(alt)
                    .foregroundStyle(.secondary)
                    .font(.callout)
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
    
    private func loadContent() async throws {
        let data = try await loadResource()
        
        do {
            // First, we look at if we can load data as SVG content.
            try await loadAsSVG(data: data)
        } catch {
            // If the content is not SVG, then try to load it as Native Image.
            #if os(macOS)
            if let image = NSImage(data: data) {
                self.image = Image(platformImage: image)
                self.imageSize = image.size
            } else {
                throw ImageError.formatError
            }
            #else
            if let image = UIImage(data: data) {
                self.image = Image(platformImage: image)
                self.imageSize = image.size
            } else {
                throw ImageError.formatError
            }
            #endif
        }
    }
}

// MARK: - Helpers

extension NetworkImage {
    private func loadResource() async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    func loadAsSVG(data: Data) async throws {
        guard let svg = String(data: data, encoding: .utf8) else { throw ImageError.notSVG }
        guard svg.starts(with: "<svg") else {
            throw ImageError.notSVG
        }
        
        #if os(watchOS) || os(tvOS)
        // This is an SVG content,
        // but this platform doesn't support WKWebView.
        isSupported = false
        #else
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
        #endif
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
