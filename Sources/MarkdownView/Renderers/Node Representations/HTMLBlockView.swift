//
//  HTMLBlockView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI
import WebKit

struct HTMLBlockView: View {
    var html: String
    @State private var contentSize = CGSize.zero
    
    var body: some View {
        HTMLView(
            "<html><body style=\"margin: 0px;width: 100%\"><div id=\"container\">\(html)</div></body></html>"
        ) { webView in
            webView.evaluateJavaScript("document.body.scrollHeight") { result, _ in
                if let height = (result as? NSNumber)?.doubleValue, height.isNormal {
                    contentSize.height = height
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: contentSize.height)
    }
}
