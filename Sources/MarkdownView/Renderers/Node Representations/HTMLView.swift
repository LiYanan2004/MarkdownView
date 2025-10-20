//
//  HTMLView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//

import SwiftUI
#if canImport(WebKit)
import WebKit
#endif

#if os(macOS)
struct HTMLView: NSViewRepresentable {
    var html: String
    var onFinishLoading: ((WKWebView) -> Void)?
    
    init(_ html: String, onFinishLoading: ((WKWebView) -> Void)? = nil) {
        self.html = html
        self.onFinishLoading = onFinishLoading
    }
    
    func makeNSView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        // MARK: Not sure if `drawsBackground` is private API.
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator.self
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
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
    var onFinishLoading: ((WKWebView) -> Void)?
    
    init(_ html: String, onFinishLoading: ((WKWebView) -> Void)? = nil) {
        self.html = html
        self.onFinishLoading = onFinishLoading
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator.self
        webView.scrollView.bounces = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        DispatchQueue.main.async {
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
