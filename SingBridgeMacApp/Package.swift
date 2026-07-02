// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "SingBridgeMacApp",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "SingBridgeCore", targets: ["SingBridgeCore"]),
    .executable(name: "SingBridgeMac", targets: ["SingBridgeMac"])
  ],
  targets: [
    .target(
      name: "SingBridgeCore",
      path: "Sources/SingBridgeCore"
    ),
    .executableTarget(
      name: "SingBridgeMac",
      dependencies: ["SingBridgeCore"],
      path: "Sources/SingBridgeMac"
    ),
    .testTarget(
      name: "SingBridgeCoreTests",
      dependencies: ["SingBridgeCore"],
      path: "Tests/SingBridgeCoreTests"
    )
  ]
)
