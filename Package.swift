// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "YUKLock",
  platforms: [
    .iOS(.v13),
  ],
  products: [
    .library(name: "YUKLock", targets: ["YUKLock"]),
  ],
  targets: [
    .target(name: "YUKLock", dependencies: []),
    .testTarget(name: "YUKLockTests", dependencies: ["YUKLock"]),
  ]
)
