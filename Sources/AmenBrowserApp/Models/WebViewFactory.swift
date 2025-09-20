import WebKit

enum WebViewFactory {
    private static let dataStore = WKWebsiteDataStore.default()

    static func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = dataStore
        configuration.defaultWebpagePreferences.preferredContentMode = .recommended
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.applicationNameForUserAgent = "AmenBrowser"
        configuration.allowsAirPlayForMediaPlayback = true
        return configuration
    }
}
