// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Automat",
    platforms: [
        .macOS(.v13),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.4"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "1.0.0-alpha.11"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),

        .package(url: "https://github.com/OperatorFoundation/Chord", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Gardener", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/KeychainCli", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Nametag", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Net", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Spacetime", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Automat",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Lifecycle", package: "swift-service-lifecycle"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIO", package: "swift-nio"),

                "Gardener",
                "KeychainCli",
                "Nametag",
                "Net",
                .product(name: "Spacetime", package: "Spacetime"),
                .product(name: "Universe", package: "Spacetime"),
            ]
        ),
        .executableTarget(
            name: "AutomatListener",
            dependencies: [
                "Automat",

                .product(name: "Simulation", package: "Spacetime"),
                .product(name: "Spacetime", package: "Spacetime"),
                .product(name: "Universe", package: "Spacetime"),
            ]
        ),
        .executableTarget(
            name: "AutomatLogicLayer",
            dependencies: [
                "Automat",

                .product(name: "Simulation", package: "Spacetime"),
                .product(name: "Spacetime", package: "Spacetime"),
                .product(name: "Universe", package: "Spacetime"),
            ]
        ),
        .executableTarget(
            name: "AutomatConnectionPool",
            dependencies: [
                "Automat",

                .product(name: "Simulation", package: "Spacetime"),
                .product(name: "Spacetime", package: "Spacetime"),
                .product(name: "Universe", package: "Spacetime"),
            ]
        ),
        .testTarget(
            name: "AutomatTests",
            dependencies: [
                "Automat",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
