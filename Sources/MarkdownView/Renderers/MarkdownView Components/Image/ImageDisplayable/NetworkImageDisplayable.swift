//
//  NetworkImageDisplayable.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

/// Load Network Images.
struct NetworkImageDisplayable: ImageDisplayable {
    func makeImage(url: URL, alt: String?) -> some View {
        NetworkImage(url: url, alt: alt)
    }
}

extension ImageDisplayable where Self == NetworkImageDisplayable {
    static var networkImage: NetworkImageDisplayable { .init() }
}
