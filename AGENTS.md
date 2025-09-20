# Repository Guidelines

## Project Structure & Module Organization
- Swift Package Manager drives the macOS app. Sources reside in `Sources/AmenBrowserApp/` split into `Components/`, `Models/`, and `ViewModels/` for SwiftUI surfaces, WebKit wrappers, and state logic.
- Extend the design system in `Theme.swift`; avoid hard-coded colors or gradients in view files.
- Add runtime assets under `Resources/` and register them in `Package.swift` when introduced.

## Build, Test, and Development Commands
- Run the app with `swift run AmenBrowserApp`; use `swift build -c release` for optimized bundles.
- Launch the generated `.build/debug/AmenBrowserApp.app` from Finder for manual QA.
- Enforce style with SwiftFormat (`swift format .`) once the toolchain is added to the repo.

## Coding Style & Naming Conventions
- Views are `PascalCase` structs in matching files; shared modifiers or components live in `Components/`.
- Keep business logic in `ObservableObject` view models (`BrowserViewModel.swift`) and encapsulate WebKit state in reference types like `BrowserTab`.
- Adopt 4-space indentation, trailing commas in multi-line literals, and organize large files with `// MARK:` pragmas.

## Testing Guidelines
- Add XCTest targets under `Tests/AmenBrowserAppTests/` mirroring source layout as behaviors settle.
- Mock WebKit dependencies (e.g., navigation delegates) so view models can be verified without spawning real webviews.
- Document new test commands in `AGENTS.md` and ensure `swift test` passes before merging.

## Commit & Pull Request Guidelines
- Use Conventional Commits (`feat:`, `fix:`, `chore:`) with ≤72 character subjects and explanatory bodies.
- PRs should include a concise summary, before/after capture for UI tweaks, manual test notes (`swift run`, navigation, tab operations), and the minimum macOS version touched.
- Tag at least one macOS maintainer and link relevant Linear/Jira issues; list any deferments under **Follow-up**.

## Security & Configuration Tips
- Do not commit secrets; manage credentials via Keychain and document entitlements in `AmenBrowserApp.entitlements` when they change.
- Keep WebKit capabilities minimal—review any new `WKWebViewConfiguration` flags during code review.
- Pin third-party packages in `Package.resolved` once dependencies are added and run `swift package audit` before release branches.
