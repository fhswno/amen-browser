import Foundation
import WebKit

final class BrowserTab: NSObject, ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String
    @Published var url: URL?
    @Published var isLoading: Bool = false
    @Published var estimatedProgress: Double = 0

    let webView: WKWebView

    override init() {
        let configuration = WebViewFactory.makeConfiguration()
        configuration.limitsNavigationsToAppBoundDomains = false

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.title = "New Tab"
        self.url = nil

        super.init()

        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) AppleWebKit/605.1.15 (KHTML, like Gecko) AmenBrowser/0.1 Safari/605.1.15"
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    func load(_ url: URL) {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20)
#if DEBUG
        print("[AmenBrowser] Loading URL: \(url.absoluteString)")
#endif
        DispatchQueue.main.async {
            self.isLoading = true
            self.webView.load(request)
        }
    }

    func loadString(_ text: String) {
        if let url = URL(fromUserInput: text) {
            load(url)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            estimatedProgress = webView.estimatedProgress
        }
    }
}

extension BrowserTab: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        #if DEBUG
        if let url = navigationAction.request.url {
            print("[AmenBrowser] Navigation action: \(url.absoluteString)")
        }
        #endif
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        #if DEBUG
        if let url = navigationResponse.response.url {
            print("[AmenBrowser] Navigation response: \(url.absoluteString)")
        }
        #endif
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true
        title = webView.url?.host ?? "Loading…"
        url = webView.url
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        title = webView.title ?? url?.absoluteString ?? "Untitled"
        url = webView.url
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        #if DEBUG
        print("[AmenBrowser] Navigation failed: \(error.localizedDescription)")
        #endif
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isLoading = false
        #if DEBUG
        print("[AmenBrowser] Provisional navigation failed: \(error.localizedDescription)")
        #endif
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            #if DEBUG
            print("[AmenBrowser] Accepting server trust for domain: \(challenge.protectionSpace.host)")
            #endif
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension BrowserTab: WKUIDelegate {}

private extension URL {
    init?(fromUserInput text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme != nil {
            self = url
            return
        }

        if let url = URL(string: "https://\(trimmed)") {
            self = url
            return
        }

        let escaped = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
        self = URL(string: "https://www.google.com/search?q=\(escaped)")!
    }
}
