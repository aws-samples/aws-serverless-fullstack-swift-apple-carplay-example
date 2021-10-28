// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name: String = "get-location"

let package = Package(
    name: name,
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(name: "swift-aws-lambda-runtime", url: "https://github.com/swift-server/swift-aws-lambda-runtime", from: "0.5.2"),
        .package(name: "AWSSwiftSDK", url: "https://github.com/awslabs/aws-sdk-swift", from: "0.0.13")
    ],
    targets: [
        .executableTarget(
            name: name,
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLocation", package: "AWSSwiftSDK")
            ]),
        .testTarget(
            name: "\(name)Tests",
            dependencies: [Target.Dependency(stringLiteral: name)]),
    ]
)
