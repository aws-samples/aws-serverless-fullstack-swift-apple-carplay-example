// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "aws-swift-app",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "GetCityFunction", targets: ["GetCityFunction"]),
        .executable(name: "GetPlacesFunction", targets: ["GetPlacesFunction"]),
        .executable(name: "GetWeatherFunction", targets: ["GetWeatherFunction"]),
        .executable(name: "CreateMessageFunction", targets: ["CreateMessageFunction"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/swift-aws-lambda-runtime", branch: "main"),
        .package(url: "https://github.com/swift-server/async-http-client", from: "1.20.1"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift", from: "0.34.0")
    ],
    targets: [
        .executableTarget(
            name: "GetCityFunction",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLocation", package: "aws-sdk-swift")
            ]
        ),
        .executableTarget(
            name: "GetPlacesFunction",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AWSLocation", package: "aws-sdk-swift")
            ]
        ),
        .executableTarget(
            name: "GetWeatherFunction",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime"),
                .product(name: "AsyncHTTPClient",package: "async-http-client"),
                .product(name: "AWSSecretsManager", package: "aws-sdk-swift")
            ]
        ),
        .executableTarget(
            name: "CreateMessageFunction",
            dependencies: [
                .product(name: "AWSLambdaRuntime", package: "swift-aws-lambda-runtime")
            ]
        )
    ]
)
