// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventStreams",
    products: [
        .library(
            name: "EventStreams",
            targets: ["EventStreams"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aetherealtech/swift-assertions", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-core-extensions", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-observer", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-scheduling", branch: "master"),
        .package(url: "https://github.com/aetherealtech/swift-synchronization", branch: "master"),
    ],
    targets: [
        .target(
            name: "EventStreams",
            dependencies: [
                .product(name: "CollectionExtensions", package: "swift-core-extensions"),
                .product(name: "Observer", package: "swift-observer"),
                .product(name: "ResultExtensions", package: "swift-core-extensions"),
                .product(name: "Scheduling", package: "swift-scheduling"),
                .product(name: "Synchronization", package: "swift-synchronization"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "EventStreamsTests",
            dependencies: [
                "EventStreams",
                .product(name: "Assertions", package: "swift-assertions"),
                .product(name: "SchedulingTestUtilities", package: "swift-scheduling"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
    ]
)

extension SwiftSetting {
    enum ConcurrencyChecking: String {
        case complete
        case minimal
        case targeted
    }
    
    static func concurrencyChecking(_ setting: ConcurrencyChecking = .minimal) -> Self {
        unsafeFlags([
            "-Xfrontend", "-strict-concurrency=\(setting)",
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
        ])
    }
}
