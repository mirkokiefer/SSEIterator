// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSEIterator",
    platforms: [
        .macOS(.v10_15) // Set the minimum macOS version to 10.15
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SSEIterator",
            targets: ["SSEIterator"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SSEIterator"),
        .testTarget(
            name: "SSEIteratorTests",
            dependencies: ["SSEIterator"]),
    ]
)
