//
//  HTMLView.swift
//  MarkdownView
//
//  Created by Yanan Li on 2025/10/20.
//  Assisted by Codex.
//

import SwiftUI
#if canImport(WebKit)
import WebKit

final class MDWebView: WKWebView {
    #if os(macOS)
    override func scrollWheel(with event: NSEvent) {
        let isHorizontalScroll = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY)
        if isHorizontalScroll {
            super.scrollWheel(with: event)
        } else {
            nextResponder?.scrollWheel(with: event)
        }
    }
    #endif
}
#endif

#if os(macOS)
struct HTMLView: NSViewRepresentable {
    var html: String
    var onContentHeightChange: ((CGFloat) -> Void)?
    var onFinishLoading: ((WKWebView) -> Void)?
    
    private var qualifiedHTML: String {
        HTMLDocumentBuilder.qualify(html)
    }
    
    init(
        _ html: String,
        onContentHeightChange: ((CGFloat) -> Void)? = nil,
        onFinishLoading: ((WKWebView) -> Void)? = nil
    ) {
        self.html = html
        self.onContentHeightChange = onContentHeightChange
        self.onFinishLoading = onFinishLoading
    }
    
    func makeNSView(context: Context) -> MDWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = MDWebView(frame: .zero, configuration: webConfiguration)
        webView.setValue(false, forKey: "drawsBackground")
        context.coordinator.configure(webView)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateNSView(_ webView: MDWebView, context: Context) {
        context.coordinator.load(html: qualifiedHTML, into: webView)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(
            onFinishLoading: onFinishLoading,
            onHeightChange: onContentHeightChange
        )
    }
}
#elseif os(iOS) || os(visionOS)
struct HTMLView: UIViewRepresentable {
    var html: String
    var onContentHeightChange: ((CGFloat) -> Void)?
    var onFinishLoading: ((WKWebView) -> Void)?
    
    private var qualifiedHTML: String {
        HTMLDocumentBuilder.qualify(html)
    }
    
    init(
        _ html: String,
        onContentHeightChange: ((CGFloat) -> Void)? = nil,
        onFinishLoading: ((WKWebView) -> Void)? = nil
    ) {
        self.html = html
        self.onContentHeightChange = onContentHeightChange
        self.onFinishLoading = onFinishLoading
    }
    
    func makeUIView(context: Context) -> MDWebView {
        let webConfiguration = WKWebViewConfiguration()
        let webView = MDWebView(frame: .zero, configuration: webConfiguration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        context.coordinator.configure(webView)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        
        return webView
    }
    
    func updateUIView(_ webView: MDWebView, context: Context) {
        context.coordinator.load(html: qualifiedHTML, into: webView)
    }
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(
            onFinishLoading: onFinishLoading,
            onHeightChange: onContentHeightChange
        )
    }
}
#endif

// MARK: - Builder

private enum HTMLDocumentBuilder {
    static let containerIdentifier = "mdv-content-container"
    
    static func qualify(_ rawHTML: String) -> String {
        let trimmed = rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.lowercased().contains("<html") == false else {
            return rawHTML
        }
        return """
        <html style="overscroll-behavior:none;width:100%;">
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        </head>
        <body style="margin:0px;">
        <div id="\(containerIdentifier)" style="width:100%;">\(rawHTML)</div>
        </body>
        </html>
        """
    }
}

// MARK: - Delegate

#if canImport(WebKit)
class WebViewCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    private enum Message {
        static let name = "markdownViewContentHeight"
    }
    
    private static let heightObserverSource = """
    (function() {
        if (window.__mdHeightObserverInstalled) {
            if (typeof window.__md_requestHeightUpdate === 'function') {
                window.__md_requestHeightUpdate();
            }
            return;
        }
        const handler = window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.\(Message.name);
        if (!handler) { return; }
        window.__mdHeightObserverInstalled = true;
        let lastSentHeight = Number.NaN;
        const containerId = "\(HTMLDocumentBuilder.containerIdentifier)";
        
        const preferredContainer = () => document.getElementById(containerId);
        
        const computeHeight = () => {
            const container = preferredContainer();
            if (container) {
                const rect = container.getBoundingClientRect();
                let height = rect && Number.isFinite(rect.height) ? rect.height : Number.NaN;
                if (!Number.isFinite(height) || height <= 0) {
                    const candidates = [container.scrollHeight, container.offsetHeight].filter((value) => Number.isFinite(value) && value > 0);
                    if (candidates.length) {
                        height = Math.max(...candidates);
                    }
                }
                if (Number.isFinite(height) && height > 0) {
                    return height;
                }
            }
            
            const body = document.body;
            const doc = document.documentElement;
            const fallbackCandidates = [
                body ? body.scrollHeight : Number.NaN,
                body ? body.offsetHeight : Number.NaN,
                doc ? doc.scrollHeight : Number.NaN,
                doc ? doc.offsetHeight : Number.NaN
            ].filter((value) => Number.isFinite(value) && value > 0);
            return fallbackCandidates.length ? Math.max(...fallbackCandidates) : Number.NaN;
        };
        
        const sendHeight = () => {
            let height = computeHeight();
            if (!Number.isFinite(height)) { return; }
            if (height < 0) { height = 0; }
            if (!Number.isFinite(lastSentHeight) || Math.abs(height - lastSentHeight) >= 0.5) {
                lastSentHeight = height;
                handler.postMessage(height);
            }
        };
        
        let heightRequestScheduled = false;
        window.__md_requestHeightUpdate = () => {
            if (heightRequestScheduled) { return; }
            heightRequestScheduled = true;
            window.requestAnimationFrame(() => {
                heightRequestScheduled = false;
                sendHeight();
            });
        };
        
        let resizeObserver = null;
        const installResizeObserver = () => {
            if (!window.ResizeObserver) { return; }
            if (resizeObserver) {
                resizeObserver.disconnect();
            }
            resizeObserver = new ResizeObserver(() => window.__md_requestHeightUpdate());
            const targets = new Set();
            const container = preferredContainer();
            if (container) { targets.add(container); }
            if (document.body) { targets.add(document.body); }
            if (document.documentElement) { targets.add(document.documentElement); }
            targets.forEach((element) => resizeObserver.observe(element));
        };
        
        let mutationObserver = null;
        const installMutationObserver = () => {
            if (!window.MutationObserver) { return; }
            if (!mutationObserver) {
                mutationObserver = new MutationObserver(() => {
                    installResizeObserver();
                    window.__md_requestHeightUpdate();
                });
            }
            mutationObserver.disconnect();
            const targets = new Set();
            const container = preferredContainer();
            if (container) { targets.add(container); }
            if (document.body) { targets.add(document.body); }
            if (document.documentElement) { targets.add(document.documentElement); }
            targets.forEach((element) => mutationObserver.observe(element, { attributes: true, childList: true, subtree: true, characterData: true }));
        };
        
        installResizeObserver();
        installMutationObserver();
        
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                installResizeObserver();
                installMutationObserver();
                window.__md_requestHeightUpdate();
            }, { once: true });
        }
        
        Array.from(document.images).forEach((image) => {
            if (image.complete) { return; }
            image.addEventListener('load', () => window.__md_requestHeightUpdate());
            image.addEventListener('error', () => window.__md_requestHeightUpdate());
        });
        
        window.addEventListener('load', () => window.__md_requestHeightUpdate());
        window.addEventListener('resize', () => window.__md_requestHeightUpdate());
        window.addEventListener('orientationchange', () => window.__md_requestHeightUpdate());
        if (window.visualViewport) {
            window.visualViewport.addEventListener('resize', () => window.__md_requestHeightUpdate());
        }
        window.__md_requestHeightUpdate();
    })();
    """
    
    private let onFinishLoading: ((WKWebView) -> Void)?
    private let onHeightChange: ((CGFloat) -> Void)?
    private weak var userContentController: WKUserContentController?
    private var lastLoadedHTML: String = ""
    private var lastReportedHeight: CGFloat = .nan
    
    init(
        onFinishLoading: ((WKWebView) -> Void)?,
        onHeightChange: ((CGFloat) -> Void)?
    ) {
        self.onFinishLoading = onFinishLoading
        self.onHeightChange = onHeightChange
        super.init()
    }
    
    func configure(_ webView: WKWebView) {
        let controller = webView.configuration.userContentController
        if userContentController !== controller {
            userContentController?.removeScriptMessageHandler(forName: Message.name)
            userContentController?.removeAllUserScripts()
            controller.removeAllUserScripts()
            controller.add(self, name: Message.name)
            let script = WKUserScript(
                source: Self.heightObserverSource,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            controller.addUserScript(script)
            userContentController = controller
        }
        lastLoadedHTML = ""
        lastReportedHeight = .nan
    }
    
    @MainActor deinit {
        userContentController?.removeScriptMessageHandler(forName: Message.name)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        lastReportedHeight = .nan
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.onFinishLoading?(webView)
        }
        requestHeightUpdate(in: webView)
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == Message.name else { return }
        guard let number = message.body as? NSNumber else { return }
        let height = CGFloat(truncating: number)
        guard height.isFinite else { return }
        if lastReportedHeight.isNaN || abs(height - lastReportedHeight) >= 0.5 {
            lastReportedHeight = height
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.onHeightChange?(height)
            }
        }
    }
    
    func load(html: String, into webView: WKWebView) {
        guard html != lastLoadedHTML else {
            requestHeightUpdate(in: webView)
            return
        }
        lastLoadedHTML = html
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func requestHeightUpdate(in webView: WKWebView) {
        webView.evaluateJavaScript(
            "window.__md_requestHeightUpdate && window.__md_requestHeightUpdate();",
            completionHandler: nil
        )
    }
}
#endif
