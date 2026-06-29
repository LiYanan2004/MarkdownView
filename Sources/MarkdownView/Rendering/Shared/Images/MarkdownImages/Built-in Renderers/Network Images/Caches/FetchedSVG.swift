//
//  FetchedSVG.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/3/29.
//

import Foundation

struct FetchedSVG: Cacheable {
    var url: URL
    var svg: SVG
    
    var cacheKey: URL { url }
    
    init(url: URL, svg: SVG) {
        self.url = url
        self.svg = svg
    }
}
