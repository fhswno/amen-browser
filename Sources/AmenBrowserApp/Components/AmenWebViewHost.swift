import AppKit
import WebKit

final class AmenWebViewHost: NSView {
    private var currentWebView: WKWebView?

    func attach(_ webView: WKWebView) {
        guard currentWebView !== webView else { return }

        currentWebView?.removeFromSuperview()
        currentWebView = webView

        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    override func layout() {
        super.layout()
        currentWebView?.setFrameOrigin(.zero)
    }
}
