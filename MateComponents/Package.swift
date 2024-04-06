// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MateComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MateComponents",
            targets: ["MateComponents"]),
    ],
    dependencies: [
        // Specify local package dependencies using the .package(path:) method
//        .package(path: "FiableFoundation"), // Local package named "FiableUI"
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MateComponents"
          
        ), // Specify dependencies for the main target),
        .testTarget(
            name: "MateComponentsTests",
            dependencies: ["MateComponents"]),
    ]
)
