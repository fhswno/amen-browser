import SwiftUI

@main
struct AmenBrowserApp: App {
    @NSApplicationDelegateAdaptor(AmenAppDelegate.self) private var appDelegate
    @StateObject private var viewModel = BrowserViewModel()

    var body: some Scene {
        WindowGroup("Amen Browser") {
            BrowserRootView(viewModel: viewModel)
                .frame(minWidth: 960, minHeight: 640)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1080, height: 720)
    }
}
