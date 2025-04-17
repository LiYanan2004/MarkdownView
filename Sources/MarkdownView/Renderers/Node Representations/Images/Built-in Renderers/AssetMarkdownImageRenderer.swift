//
//  AssetMarkdownImageRenderer.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

/// A markdown image renderer that loads images from asset catalog.
struct AssetMarkdownImageRenderer: MarkdownImageRenderer {
    var name: (URL) -> String
    var bundle: Bundle?
    
    func makeBody(configuration: Configuration) -> some View {
        let (url, alt) = (configuration.url, configuration.alternativeText)
        #if os(macOS)
        let nsImage: NSImage?
        if let bundle = bundle, bundle != .main {
            nsImage = bundle.image(forResource: name(url))
        } else {
            nsImage = NSImage(named: name(url))
        }
        if let nsImage {
            return MainActor.assumeIsolated {
                AssetImage(image: nsImage, alt: alt)
            }
        }
        #elseif os(iOS) || os(tvOS)
        if let uiImage = UIImage(named: name(url), in: bundle, compatibleWith: nil) {
            return MainActor.assumeIsolated {
                AssetImage(image: uiImage, alt: alt)
            }
        }
        #elseif os(watchOS)
        if let uiImage = UIImage(named: name(url), in: bundle, with: nil) {
            return MainActor.assumeIsolated {
                AssetImage(image: uiImage, alt: alt)
            }
        }
        #endif
        return MainActor.assumeIsolated {
            AssetImage(image: nil, alt: nil)
        }
    }
}

extension MarkdownImageRenderer where Self == AssetMarkdownImageRenderer {
    static func assetImage(name: @escaping (URL) -> String = \.lastPathComponent, bundle: Bundle? = nil) -> AssetMarkdownImageRenderer {
        AssetMarkdownImageRenderer(name: name, bundle: bundle)
    }
}

// MARK: - Auxiliary

fileprivate struct AssetImage: View {
    var image: PlatformImage?
    var alt: String?
    
    var body: some View {
        if let image {
            Image(platformImage: image)
                .resizable().aspectRatio(contentMode: .fit)
            if let alt {
                Text(alt).foregroundStyle(.secondary).font(.callout)
            }
        } else {
            ImagePlaceholder()
        }
    }
}
