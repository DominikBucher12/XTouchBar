// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "XcodeCommandBridgeClient",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "XcodeCommandBridgeClient", targets: ["XcodeCommandBridgeClient"]),
        .executable(name: "xcb", targets: ["XcodeBridgeCLI"])
    ],
    targets: [
        .target(name: "XcodeCommandBridgeClient", path: "Client/Sources/XcodeCommandBridgeClient"),
        .executableTarget(name: "XcodeBridgeCLI", dependencies: ["XcodeCommandBridgeClient"], path: "CLI"),
        .testTarget(name: "XcodeCommandBridgeClientTests", dependencies: ["XcodeCommandBridgeClient"], path: "Tests/Client")
    ]
)
