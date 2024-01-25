// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name: String = "get-places"

let package = Package(
    name: name,
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", branch: "main"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "0.34.0")
    ],
    targets: [
        .executableTarget(
            name: name,
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLocation", package: "aws-sdk-swift")
            ]),
        .testTarget(
            name: "\(name)Tests",
            dependencies: [Target.Dependency(stringLiteral: name)]),
    ]
)
