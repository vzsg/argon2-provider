// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Argon2Provider",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
        .Package(url: "https://github.com/vzsg/argon2.git", majorVersion: 0, minor: 2)
    ]
)
