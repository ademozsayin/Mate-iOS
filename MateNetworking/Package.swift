// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MateNetworking",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MateNetworking",
            targets: ["MateNetworking"]),
    ],
    dependencies: [
        .package(path: "FiableFoundation"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MateNetworking",
            dependencies: [
                "Alamofire",
                "CocoaLumberjack",
                "FiableFoundation",
                "KeychainAccess"
            ]),
        .testTarget(
            name: "MateNetworkingTests",
            dependencies: ["MateNetworking"]),
    ]
)


   
