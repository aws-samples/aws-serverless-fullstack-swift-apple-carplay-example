// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name: String = "get-weather"

let package = Package(
    name: name,
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", branch: "main"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.13.1"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "0.9.0")
    ],
    targets: [
        .executableTarget(
            name: name,
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AsyncHTTPClient",package: "async-http-client"),
                .product(name: "AWSSecretsManager", package: "aws-sdk-swift")
            ]),
        .testTarget(
            name: "\(name)Tests",
            dependencies: [Target.Dependency(stringLiteral: name)]),
    ]
)