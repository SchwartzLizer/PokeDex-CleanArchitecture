// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "YourProjectDanger",
    products: [
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "3.15.0"),
        .package(url: "https://github.com/f-meloni/danger-swiftlint", from: "1.0.0")
    ],
    targets: [
        .target(name: "DangerDependencies", dependencies: ["Danger"]),
    ]
)
