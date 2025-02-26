//
//  AssetImageDisplayable.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

/// Load images from your Assets Catalog.
struct AssetImageDisplayable: ImageDisplayable {
    var name: (URL) -> String
    var bundle: Bundle?
    
    func makeImage(url: URL, alt: String?) -> some View {
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

extension ImageDisplayable where Self == AssetImageDisplayable {
    static func assetImage(name: @escaping (URL) -> String = \.lastPathComponent, bundle: Bundle? = nil) -> AssetImageDisplayable {
        AssetImageDisplayable(name: name, bundle: bundle)
    }
}
