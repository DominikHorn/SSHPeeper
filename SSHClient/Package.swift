// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SSHClient",
    platforms: [
      .macOS(.v12),
      .iOS(.v15),
      .watchOS(.v8),
      .tvOS(.v15)
    ],
    products: [
        .library(
            name: "SSHClient",
            targets: ["SSHClient"]),
    ],
    dependencies: [
      .package(url: "git@github.com:DominikHorn/swift-nio-ssh.git", branch: "feature/userauth-banners")
    ],
    targets: [
        .target(
            name: "SSHClient",
            dependencies: [
              .product(name: "NIOSSH", package: "swift-nio-ssh")
            ]),
        .testTarget(
            name: "SSHClientTests",
            dependencies: ["SSHClient"]),
    ]
)
