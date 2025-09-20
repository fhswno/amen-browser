// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AmenBrowser",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "AmenBrowserApp",
            targets: ["AmenBrowserApp"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AmenBrowserApp",
            path: "Sources/AmenBrowserApp"
        )
    ]
)
