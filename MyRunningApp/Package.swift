// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "MyRunningApp",
  platforms: [
    .macOS(.v14)
  ],
  dependencies: [],
  targets: [
    .executableTarget(
      name: "MyRunningApp",
      dependencies: [],
      path: "Sources/MyRunningApp"
    )
  ]
)
