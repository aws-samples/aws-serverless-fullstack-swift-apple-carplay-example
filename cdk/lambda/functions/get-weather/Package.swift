// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name: String = "get-weather"

let package = Package(
    name: name,
    platforms: [.macOS(.v10_14)],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime.git", .upToNextMajor(from:"0.3.0")),
        .package(url: "https://github.com/swift-server/async-http-client", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/soto-project/soto.git", .upToNextMajor(from:"5.0.0"))
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                .product(name: "AWSLambdaRuntime",package: "swift-aws-lambda-runtime"),
                .product(name: "AsyncHTTPClient",package: "async-http-client"),
                .product(name: "SotoSecretsManager", package: "soto")
            ]),
        .testTarget(
            name: "\(name)Tests",
            dependencies: [Target.Dependency(stringLiteral: name)]),
    ]
)

