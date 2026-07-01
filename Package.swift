// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "SingBridge",
  platforms: [
    .iOS(.v17),
    .macOS(.v14)
  ],
  products: [
    .library(name: "SingBridgeCore", targets: ["SingBridgeCore"]),
    .executable(name: "SingBridgePhone", targets: ["SingBridgePhone"]),
    .executable(name: "SingBridgeMac", targets: ["SingBridgeMac"])
  ],
  targets: [
    .target(name: "SingBridgeCore"),
    .executableTarget(
      name: "SingBridgePhone",
      dependencies: ["SingBridgeCore"]
    ),
    .executableTarget(
      name: "SingBridgeMac",
      dependencies: ["SingBridgeCore"]
    ),
    .testTarget(
      name: "SingBridgeCoreTests",
      dependencies: ["SingBridgeCore"]
    )
  ]
)
