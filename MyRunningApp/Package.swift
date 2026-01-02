// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "MyRunningApp",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
  ],
  targets: [
    .executableTarget(
      name: "MyRunningApp",
      dependencies: [
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
      ],
      path: "Sources/MyRunningApp",
      resources: [
        .process("Info.plist"),
        .process("GoogleService-Info.plist"),
      ]
    )
  ]
)
