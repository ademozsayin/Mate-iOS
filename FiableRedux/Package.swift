// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FiableRedux",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FiableRedux",
            targets: ["FiableRedux"]),
    ],
    dependencies: [
        // Specify local package dependencies using the .package(path:) method
        .package(path: "MateNetworking"),
        .package(path: "FiableFoundation"),
        .package(path: "MateStorage"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "FiableRedux",
            dependencies: [
                "MateNetworking",
                "FiableFoundation",
                "MateStorage",
                "CocoaLumberjack"]
        ),
        .testTarget(
            name: "FiableReduxTests",
            dependencies: ["FiableRedux"]),
    ]
)




