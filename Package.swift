// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Logger",
            targets: ["Logger"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "Logger",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
            ])
    ]
)
