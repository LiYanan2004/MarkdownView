import SwiftUI
#if canImport(WebKit)
import WebKit
#endif

#if os(macOS)
struct SVGView: NSViewRepresentable {
    var html: String
    
    func makeNSView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        // MARK: Not sure if `drawsBackground` is private API.
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        DispatchQueue.main.async {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
}
#elseif os(iOS)
struct SVGView: UIViewRepresentable {
    var html: String

    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        DispatchQueue.main.async {
            webView.loadHTMLString(html, baseURL: nil)
            // Scale a little bit to fit the size.
            webView.pageZoom = 4
        }
    }
}
#endif
