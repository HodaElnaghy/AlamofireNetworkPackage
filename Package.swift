// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AlamofireNetwork",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AlamofireNetwork",
            targets: ["AlamofireNetwork"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1")
    ],
    targets: [
        .target(
            name: "AlamofireNetwork",
            dependencies: ["Alamofire"]),
        .testTarget(
            name: "AlamofireNetworkTests",
            dependencies: ["AlamofireNetwork"]),
    ]
)
