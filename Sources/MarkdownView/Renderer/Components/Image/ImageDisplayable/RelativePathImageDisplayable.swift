//
//  RelativePathImageDisplayable.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

/// Load Images from relative path urls.
struct RelativePathImageDisplayable: ImageDisplayable {
    var baseURL: URL
    
    func makeImage(url: URL, alt: String?) -> some View {
        let completeURL = baseURL.appendingPathComponent(url.absoluteString)
        NetworkImage(url: completeURL, alt: alt)
    }
}

extension ImageDisplayable where Self == RelativePathImageDisplayable {
    static func relativePathImage(baseURL: URL) -> RelativePathImageDisplayable {
        RelativePathImageDisplayable(baseURL: baseURL)
    }
}
