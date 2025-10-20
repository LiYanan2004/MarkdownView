//
//  HTMLView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI
#if canImport(WebKit)
import WebKit

final class MDWebView: WKWebView {
    #if os(macOS)
    override func scrollWheel(with event: NSEvent) {
        nextResponder?.scrollWheel(with: event)
        return
    }
    #endif
}
#endif


#if os(macOS)
struct HTMLView: NSViewRepresentable {
    var html: String
    var onFinishLoading: ((WKWebView) -> Void)?
    
    init(_ html: String, onFinishLoading: ((WKWebView) -> Void)? = nil) {
        self.html = html
        self.onFinishLoading = onFinishLoading
    }
    
    func makeNSView(context: Context) -> MDWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = MDWebView(frame: .zero, configuration: webConfiguration)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator.self
        return webView
    }
    
    func updateNSView(_ webView: MDWebView, context: Context) {
        DispatchQueue.main.async {
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func makeCoordinator() -> WebViewDelegate {
        WebViewDelegate(onFinishLoading: onFinishLoading)
    }
}
#elseif os(iOS) || os(visionOS)
struct HTMLView: UIViewRepresentable {
    var html: String
    @State private var _html: String = ""
    var onFinishLoading: ((WKWebView) -> Void)?
    
    init(_ html: String, onFinishLoading: ((WKWebView) -> Void)? = nil) {
        self.html = html
        self.onFinishLoading = onFinishLoading
    }
    
    func makeUIView(context: Context) -> MDWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = MDWebView(frame: .zero, configuration: webConfiguration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator.self
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        
        return webView
    }
    
    func updateUIView(_ webView: MDWebView, context: Context) {
        DispatchQueue.main.async {
            self._html = html
            webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func makeCoordinator() -> WebViewDelegate {
        WebViewDelegate(onFinishLoading: onFinishLoading)
    }
}
#endif

// MARK: - Delegate

#if canImport(WebKit)
@MainActor
class WebViewDelegate: NSObject, WKNavigationDelegate {
    var onFinishLoading: ((WKWebView) -> Void)?
    
    init(onFinishLoading: ((WKWebView) -> Void)?) {
        self.onFinishLoading = onFinishLoading
    }
    
    nonisolated func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MainActor.assumeIsolated {
            onFinishLoading?(webView)
        }
    }
}
#endif
