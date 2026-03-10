//
//  File.swift
//  MarkdownViewExample
//
//  Created by Yanan Li on 2026/3/10.
//

import DeveloperToolsSupport
import SwiftUI

struct MarkdownViewPreviewModifier: PreviewModifier {
    typealias Context = Void
    
    func body(content: Content, context: Context) -> some View {
        ScrollView {
            content
                .scenePadding()
        }
    }
}

@available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension PreviewTrait where T == Preview.ViewTraits {
    static var markdownViewExample: Self {
        .modifier(MarkdownViewPreviewModifier())
    }
}
