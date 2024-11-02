// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleanArchitectureUseCase",
    platforms: [.iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CleanArchitectureUseCase",
            targets: ["CleanArchitectureUseCase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt",
                 .upToNextMajor(from: "1.8.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CleanArchitectureUseCase",
            dependencies: [
                .product(name: "CombineExt", package: "CombineExt")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CleanArchitectureUseCaseTests",
            dependencies: ["CleanArchitectureUseCase"]
        ),
    ]
)
