import SwiftUI
#if os(macOS)
import AppKit
#endif

struct BrowserRootView: View {
    @ObservedObject var viewModel: BrowserViewModel
    @FocusState private var focusedField: Field?

    enum Field {
        case address
    }

    var body: some View {
        ZStack {
            AmenTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topChrome
                Divider()
                    .overlay(AmenTheme.tertiaryText.opacity(0.18))

                if let tab = viewModel.selectedTab {
                    ZStack {
                        WebViewContainer(tab: tab)
                            .background(AmenTheme.background)

                        if tab.url == nil && !tab.isLoading {
                            StartPageView(viewModel: viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    placeholder
                }
            }
            .background(AmenTheme.background)
        }
        .onAppear {
#if os(macOS)
            NSApp.activate(ignoringOtherApps: true)
#endif
            focusedField = .address
        }
        .onChange(of: viewModel.selectedTabID) { _ in
            focusedField = .address
        }
    }

    private var topChrome: some View {
        VStack(spacing: 14) {
            tabStrip
            commandRow
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 16)
        .background(
            AmenTheme.chromeGradient
                .overlay(Color.white.opacity(0.08))
                .shadow(color: AmenTheme.toolbarShadow, radius: 26, y: 18)
        )
    }

    private var tabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.orderedTabs) { tab in
                    TabChipView(
                        tab: tab,
                        isActive: tab.id == viewModel.selectedTabID,
                        onSelect: { viewModel.selectTab(tab) },
                        onClose: { viewModel.closeTab(tab) }
                    )
                }

                Button(action: {
                    viewModel.newTab()
                    focusedField = .address
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .frame(width: 28, height: 28)
                        .background(AmenTheme.glassBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .stroke(AmenTheme.tintedStroke, lineWidth: 0.8)
                        )
                        .foregroundColor(AmenTheme.primaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
    }

    private var commandRow: some View {
        HStack(spacing: 14) {
            HStack(spacing: 10) {
                ToolbarIconButton(systemImage: "chevron.left") {
                    viewModel.goBack()
                }
                .disabled(!(viewModel.selectedTab?.webView.canGoBack ?? false))

                ToolbarIconButton(systemImage: "chevron.right") {
                    viewModel.goForward()
                }
                .disabled(!(viewModel.selectedTab?.webView.canGoForward ?? false))

                ToolbarIconButton(systemImage: viewModel.selectedTab?.isLoading == true ? "xmark" : "arrow.clockwise") {
                    if viewModel.selectedTab?.isLoading == true {
                        viewModel.stopLoading()
                    } else {
                        viewModel.reload()
                    }
                }
            }

            AddressField(
                text: Binding(
                    get: { viewModel.addressFieldText },
                    set: { viewModel.updateAddressField(with: $0) }
                ),
                progress: viewModel.selectedTab?.estimatedProgress ?? 0,
                isLoading: viewModel.selectedTab?.isLoading ?? false,
                onSubmit: viewModel.openAddressBarEntry,
                onEditingChanged: { editing in
                    if editing {
                        focusedField = .address
                        viewModel.beginAddressEditing()
                    } else {
                        focusedField = nil
                        viewModel.endAddressEditing()
                    }
                },
                isFirstResponder: focusedField == .address
            )

            ToolbarIconButton(systemImage: "rectangle.and.text.magnifyingglass") {
                viewModel.isShowingInspector.toggle()
            }
        }
        .padding(.horizontal, 4)
    }

    private var placeholder: some View {
        VStack(spacing: 12) {
            Text("Welcome to Amen")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
            Text("Open a new tab and start exploring the web with focus.")
                .foregroundColor(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AmenTheme.background)
    }
}

private struct ToolbarIconButton: View {
    @Environment(\.isEnabled) private var isEnabled

    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(isEnabled ? AmenTheme.primaryText : AmenTheme.secondaryText.opacity(0.4))
                .frame(width: 32, height: 32)
                .background(AmenTheme.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AmenTheme.tintedStroke, lineWidth: 0.8)
                )
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

private struct AddressField: View {
    @Binding var text: String
    let progress: Double
    let isLoading: Bool
    let onSubmit: () -> Void
    let onEditingChanged: (Bool) -> Void
    let isFirstResponder: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AmenTheme.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AmenTheme.tintedStroke, lineWidth: 0.9)
                )
                .shadow(color: AmenTheme.toolbarShadow.opacity(0.35), radius: 16, y: 12)
                .allowsHitTesting(false)

            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AmenTheme.accent.opacity(0.26))
                    .frame(width: geometry.size.width * CGFloat(progress))
                    .opacity(isLoading ? 1 : 0)
                    .animation(.easeOut(duration: 0.35), value: progress)
            }
            .allowsHitTesting(false)

            HStack(spacing: 10) {
                Image(systemName: isLoading ? "slowmo" : "globe")
                    .foregroundStyle(AmenTheme.secondaryText)
                    .padding(.leading, 14)

                AmenTextField(
                    text: $text,
                    placeholder: "Search or type URL",
                    font: .systemFont(ofSize: 14, weight: .medium),
                    textColor: AmenTheme.primaryNSColor,
                    accentColor: AmenTheme.accentNSColor,
                    isFirstResponder: isFirstResponder,
                    onEditingChanged: onEditingChanged,
                    onCommit: onSubmit
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)

                if !text.isEmpty {
                    Button {
                        text.removeAll()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AmenTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 12)
                } else {
                    Spacer().frame(width: 12)
                }
            }
        }
        .frame(height: 40)
    }
}

private struct TabChipView: View {
    @ObservedObject var tab: BrowserTab
    let isActive: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
            Capsule()
                .fill(isActive ? AmenTheme.accent : AmenTheme.glassBackground)
                .frame(width: 6, height: 24)
                .opacity(isActive ? 1 : 0.35)

            VStack(alignment: .leading, spacing: 2) {
                Text(tab.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .foregroundColor(isActive ? AmenTheme.primaryText : AmenTheme.secondaryText)
                Text(tab.url?.host ?? "")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(AmenTheme.secondaryText)
                    .lineLimit(1)
            }

                Spacer(minLength: 6)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AmenTheme.secondaryText)
                        .frame(width: 18, height: 18)
                        .background(AmenTheme.glassBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.16) : AmenTheme.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AmenTheme.tintedStroke.opacity(isActive ? 0.6 : 0.3), lineWidth: 0.8)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct StartPageView: View {
    @ObservedObject var viewModel: BrowserViewModel

    var body: some View {
        VStack(spacing: 36) {
            VStack(spacing: 12) {
                Text("Amen Browser")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                Text("Crafted for developers who demand focus and flow.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }

            HStack(spacing: 20) {
                QuickActionButton(title: "Open Home", systemImage: "house.fill") {
                    viewModel.goHome()
                }

                QuickActionButton(title: "Visit Docs", systemImage: "doc.richtext") {
                    viewModel.openAddressBarEntryWith("https://docs.sl-yt.com")
                }

                QuickActionButton(title: "Launch Google", systemImage: "magnifyingglass") {
                    viewModel.openAddressBarEntryWith("https://www.google.com")
                }
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.29, green: 0.59, blue: 0.46).opacity(0.45),
                    AmenTheme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private struct QuickActionButton: View {
        let title: String
        let systemImage: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AmenTheme.primaryText)
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AmenTheme.primaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(AmenTheme.glassBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AmenTheme.tintedStroke, lineWidth: 0.9)
                )
            }
            .buttonStyle(.plain)
        }
    }
}
