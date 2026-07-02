// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "SingBridgePhoneApp",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    .library(name: "SingBridgeCore", targets: ["SingBridgeCore"]),
    .executable(name: "SingBridgePhone", targets: ["SingBridgePhone"])
  ],
  targets: [
    .target(
      name: "SingBridgeCore",
      path: "Sources/SingBridgeCore"
    ),
    .executableTarget(
      name: "SingBridgePhone",
      dependencies: ["SingBridgeCore"],
      path: "Sources/SingBridgePhone"
    ),
    .testTarget(
      name: "SingBridgeCoreTests",
      dependencies: ["SingBridgeCore"],
      path: "Tests/SingBridgeCoreTests"
    )
  ]
)
