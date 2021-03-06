// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "YUKLock",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "YUKLock", targets: ["YUKLock"]),
  ],
  targets: [
    .target(name: "YUKLock"),
    .testTarget(name: "YUKLockTests", dependencies: ["YUKLock"]),
  ]
)
