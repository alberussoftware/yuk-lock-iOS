// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "YUKLock",
  platforms: [
    .iOS(.v14),
    .macOS(.v11),
  ],
  products: [
    .library(name: "YUKLock", targets: ["YUKLock"]),
  ],
  targets: [
    .target(name: "YUKLock"),
    .testTarget(name: "YUKLockTests", dependencies: ["YUKLock"]),
  ]
)
