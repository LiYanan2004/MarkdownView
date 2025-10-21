//
//  HTMLBlockView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI

struct HTMLBlockView: View {
    var html: String
    @State private var contentSize = CGSize.zero
    
    var body: some View {
        // FIXME: Dynamic height not supported.
        HTMLView(
            "<html style=\"overscroll-behavior:none;width:100%;\"><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"></head><body style=\"margin:0px;\"><div id=\"container\">\(html)</div></body></html>"
        ) { webView in
            webView.evaluateJavaScript(
                "document.body.scrollHeight"
            ) { result, _ in
                if let height = (result as? NSNumber)?.doubleValue, height.isNormal {
                    contentSize.height = height
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: contentSize.height)
        .frame(height: contentSize.height)
    }
}
