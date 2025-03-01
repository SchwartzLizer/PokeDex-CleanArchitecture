// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "YourProjectDanger",
    products: [
        .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]),
    ],
    dependencies: [
        .package(url: "https://github.com/danger/swift.git", from: "3.15.0"),
        // Add any Danger plugins you need, for example:
        // .package(url: "https://github.com/JohnSundell/SwiftLint", from: "0.47.1"),
    ],
    targets: [
        .target(name: "DangerDependencies", dependencies: ["Danger"]),
    ]
)
