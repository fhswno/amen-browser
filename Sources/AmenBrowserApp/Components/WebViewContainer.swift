import SwiftUI
import WebKit

struct WebViewContainer: NSViewRepresentable {
    typealias NSViewType = AmenWebViewHost

    let tab: BrowserTab

    func makeNSView(context: Context) -> AmenWebViewHost {
        let host = AmenWebViewHost()
        host.attach(tab.webView)
        return host
    }

    func updateNSView(_ nsView: AmenWebViewHost, context: Context) {
        nsView.attach(tab.webView)
    }
}
