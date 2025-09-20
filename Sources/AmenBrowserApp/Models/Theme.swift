import SwiftUI
#if os(macOS)
import AppKit
#endif

enum AmenTheme {
    static let chromeGradient = LinearGradient(
        colors: [
            Color(red: 0.29, green: 0.59, blue: 0.46),
            Color(red: 0.95, green: 0.97, blue: 0.86)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassBackground = Color.white.opacity(0.22)
    static let tintedStroke = Color.white.opacity(0.45)
    static let accent = Color(red: 0.39, green: 0.67, blue: 0.31)
    static let primaryText = Color(red: 0.10, green: 0.15, blue: 0.12)
    static let secondaryText = Color(red: 0.33, green: 0.41, blue: 0.36)
    static let tertiaryText = Color.black.opacity(0.28)
    static let toolbarShadow = Color.black.opacity(0.20)
    static let background = Color(red: 0.05, green: 0.07, blue: 0.08)

#if os(macOS)
    static let primaryNSColor = NSColor(calibratedRed: 0.10, green: 0.15, blue: 0.12, alpha: 1.0)
    static let secondaryNSColor = NSColor(calibratedRed: 0.33, green: 0.41, blue: 0.36, alpha: 1.0)
    static let accentNSColor = NSColor(calibratedRed: 0.39, green: 0.67, blue: 0.31, alpha: 1.0)
#endif
}
