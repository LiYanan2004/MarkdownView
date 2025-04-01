//
//  FetchedImage.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import SwiftUI

struct FetchedImage: Cacheable {
    var url: URL
    var image: Image
    var size: CGSize
    
    var cacheKey: URL { url }
    
    init(url: URL, image: Image, size: CGSize) {
        self.url = url
        self.image = image
        self.size = size
    }
}
