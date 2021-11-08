// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWCompositionalLayout",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "WWCompositionalLayout", targets: ["WWCompositionalLayout"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WWCompositionalLayout", dependencies: []),
        .testTarget(name: "WWCompositionalLayoutTests", dependencies: ["WWCompositionalLayout"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
