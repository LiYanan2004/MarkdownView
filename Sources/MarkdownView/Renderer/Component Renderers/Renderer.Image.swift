//
//  Renderer.Image.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI
import Markdown

extension Renderer {
    mutating func visitImage(_ image: Markdown.Image) -> Result {
        guard let source = URL(string: image.source ?? "") else {
            return Result(SwiftUI.Text(image.plainText))
        }

        let alt: String?
        if !(image.parent is Markdown.Link) {
            if let title = image.title, !title.isEmpty {
                alt = title
            } else {
                alt = image.plainText.isEmpty ? nil : image.plainText
            }
        } else {
            // If the image is inside a link, then ignore the alternative text
            alt = nil
        }
        
        var provider: (any ImageDisplayable)?
        if let scheme = source.scheme {
            imageRenderer.imageProviders.forEach { key, value in
                if scheme.localizedLowercase == key.localizedLowercase {
                    provider = value
                    return
                }
            }
        }
        
        return Result(imageRenderer.loadImage(provider, url: source, alt: alt))
    }
}
