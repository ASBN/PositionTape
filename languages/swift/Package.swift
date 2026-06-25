// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PositionTape",
    products: [
        .library(name: "PositionTape", targets: ["PositionTape"])
    ],
    targets: [
        .target(name: "PositionTape", path: "src"),
        .executableTarget(
            name: "PositionTapeTests",
            dependencies: ["PositionTape"],
            path: "tests"
        )
    ]
)
