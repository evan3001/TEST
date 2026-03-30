// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusSync",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FocusSyncCore",
            targets: ["FocusSyncCore"]
        ),
    ],
    targets: [
        .target(
            name: "FocusSyncCore",
            path: "Shared"
        ),
    ]
)
