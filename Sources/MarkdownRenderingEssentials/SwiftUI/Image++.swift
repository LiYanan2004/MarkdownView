//
//  Image++.swift
//  MarkdownView
//
//  Created by LiYanan2004 on 2024/12/11.
//

import SwiftUI

#if os(macOS)
package typealias PlatformImage = NSImage
#else
package typealias PlatformImage = UIImage
#endif

extension Image {
    package init(platformImage: PlatformImage) {
        #if os(macOS)
        self.init(nsImage: platformImage)
        #else
        self.init(uiImage: platformImage)
        #endif
    }
}
