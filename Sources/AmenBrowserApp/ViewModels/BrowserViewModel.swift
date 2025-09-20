import Combine
import Foundation

final class BrowserViewModel: ObservableObject {
    private let homeURL = URL(string: "https://www.davidohayon.uk")!
    private let fallbackURL = URL(string: "https://www.google.com")!

    @Published private(set) var tabs: [BrowserTab]
    @Published var selectedTabID: BrowserTab.ID
    @Published var addressFieldText: String = ""
    @Published var isShowingInspector: Bool = false
    @Published private(set) var isAddressEditing: Bool = false

    private var tabSubscriptions: [BrowserTab.ID: Set<AnyCancellable>] = [:]
    private var cancellables = Set<AnyCancellable>()

    init() {
        let initialTab = BrowserTab()
        self.tabs = [initialTab]
        self.selectedTabID = initialTab.id
        bind(tab: initialTab)

        addressFieldText = homeURL.absoluteString
        initialTab.load(homeURL)

        $selectedTabID
            .sink { [weak self] id in
                guard let self, let tab = self.tab(with: id) else { return }
                if !self.isAddressEditing {
                    self.addressFieldText = tab.url?.absoluteString ?? ""
                }
            }
            .store(in: &cancellables)
    }

    var orderedTabs: [BrowserTab] { tabs }

    var selectedTab: BrowserTab? { tab(with: selectedTabID) }

    func tab(with id: BrowserTab.ID) -> BrowserTab? {
        tabs.first(where: { $0.id == id })
    }

    func openAddressBarEntry() {
        let text = addressFieldText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isAddressEditing = false
#if DEBUG
        print("[AmenBrowser] openAddressBarEntry navigating to: \(text)")
#endif
        selectedTab?.loadString(text)
    }

    func openAddressBarEntryWith(_ value: String) {
        addressFieldText = value
        openAddressBarEntry()
    }

    func updateAddressField(with text: String) {
        addressFieldText = text
    }

    func beginAddressEditing() {
        isAddressEditing = true
    }

    func endAddressEditing() {
        isAddressEditing = false
        if let currentURL = selectedTab?.url?.absoluteString {
            addressFieldText = currentURL
        }
    }

    func newTab(with url: URL? = nil) {
        let tab = BrowserTab()
        tabs.append(tab)
        bind(tab: tab)
        selectedTabID = tab.id

        if let destination = url {
            addressFieldText = destination.absoluteString
            tab.load(destination)
        } else {
            addressFieldText = ""
        }
    }

    func closeTab(_ tab: BrowserTab) {
        guard tabs.count > 1 else {
            tab.load(fallbackURL)
            addressFieldText = fallbackURL.absoluteString
            return
        }

        tabs.removeAll { $0.id == tab.id }
        tabSubscriptions[tab.id]?.forEach { $0.cancel() }
        tabSubscriptions[tab.id] = nil

        if selectedTabID == tab.id, let fallback = tabs.last {
            selectedTabID = fallback.id
        }
    }

    func selectTab(_ tab: BrowserTab) {
        selectedTabID = tab.id
    }

    func goBack() { selectedTab?.webView.goBack() }
    func goForward() { selectedTab?.webView.goForward() }
    func reload() {
        if selectedTab?.isLoading == true {
            stopLoading()
        } else {
            selectedTab?.webView.reloadFromOrigin()
        }
    }
    func stopLoading() { selectedTab?.webView.stopLoading() }

    func goHome() {
        guard let current = selectedTab else { return }
        isAddressEditing = false
        current.load(homeURL)
        updateAddressField(with: homeURL.absoluteString)
    }

    private func bind(tab: BrowserTab) {
        var bag = Set<AnyCancellable>()

        tab.$url
            .receive(on: RunLoop.main)
            .sink { [weak self, weak tab] value in
                guard let self, let tab else { return }
                if tab.id == self.selectedTabID, !self.isAddressEditing {
                    self.addressFieldText = value?.absoluteString ?? ""
                }
            }
            .store(in: &bag)

        tabSubscriptions[tab.id] = bag
    }
}
