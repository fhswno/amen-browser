# Amen Browser

Amen is a native macOS web browser focused on performance, developer ergonomics, and a refined aesthetic inspired by Jony Ive-era Apple design. This first milestone provides a functional browser shell with a custom SwiftUI chrome, tab management, and a high-polish gradient interface.

## Getting Started

1. Install Xcode 15 or the latest developer tools for macOS 13+.
2. From the repository root, build and launch the app:

   ```bash
   swift run AmenBrowserApp
   ```

   The build artifacts live in `.build/`. You can open the generated `AmenBrowserApp` bundle directly from Finder after building.

## Current Feature Set

- Multi-tab support with animated, chip-style tab strip.
- Back, forward, reload/stop controls and omnibox entry.
- Address heuristics that accept raw URLs or search terms.
- WKWebView-powered content area with progress indicator.
- Apple-inspired gradient chrome with glassmorphism detailing.

## Roadmap Highlights

- Workspace presets tied to Git branches and dev scripts.
- Integrated inspector overlays (network, console, log stream).
- Cloud sync for tabs, profiles, and theme tokens.
- Extension SDK for deep developer tooling integrations.

Contributions welcome—see `AGENTS.md` for detailed guidelines.
