// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name: String = "get-weather"

let package = Package(
    name: name,
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(name: "swift-aws-lambda-runtime", url: "https://github.com/swift-server/swift-aws-lambda-runtime", from: "0.5.2"),
        .package(name: "async-http-client", url: "https://github.com/swift-server/async-http-client", .upToNextMajor(from: "1.6.3")),
        .package(name: "AWSSwiftSDK", url: "https://github.com/awslabs/aws-sdk-swift", from: "0.0.13")
    ],
    targets: [
        .executableTarget(
            name: name,
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AsyncHTTPClient",package: "async-http-client"),
                .product(name: "AWSSecretsManager", package: "AWSSwiftSDK")
            ]),
        .testTarget(
            name: "\(name)Tests",
            dependencies: [Target.Dependency(stringLiteral: name)]),
    ]
)