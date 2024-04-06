// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MateStorage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MateStorage",
            targets: ["MateStorage"]),
    ],
    dependencies: [
        // Specify local package dependencies using the .package(path:) method
        .package(path: "FiableFoundation"), // Local package named "MateFoundation"
        .package(path: "CodeGen"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MateStorage",
            dependencies: [
                "FiableFoundation",
                "CodeGen"
            ]),
        .testTarget(
            name: "MateStorageTests",
            dependencies: ["MateStorage"]),
    ]
)



