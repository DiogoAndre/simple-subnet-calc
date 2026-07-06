// swift-tools-version: 6.1
//
// Linux test harness for Simple Subnet Calc.
//
// The app itself is an Xcode/iOS project, but the calculators and their unit
// tests are pure Swift (Foundation + swift-cidr only), so they can build and
// run anywhere a Swift 6.1+ toolchain exists — including Claude Code on the
// web sessions and Linux CI. The sources and tests are SYMLINKS into the real
// app tree; nothing is duplicated, and edits to the app flow through
// automatically.
//
// Run with:  swift test   (from this directory)

import PackageDescription

let package = Package(
    name: "SimpleSubnetCalcHarness",
    platforms: [
        .macOS(.v15) // for UInt128; ignored on Linux
    ],
    dependencies: [
        // Same pin as the Xcode project (up-to-next-minor from 0.2.0).
        .package(url: "https://github.com/RouteObjects/swift-cidr.git", .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(
            name: "Simple_Subnet_Calc", // must match the app's module name for @testable import
            dependencies: [
                .product(name: "CIDR", package: "swift-cidr"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5), // mirrors the Xcode project's SWIFT_VERSION = 5.0
            ]
        ),
        .testTarget(
            name: "SSCTests",
            dependencies: ["Simple_Subnet_Calc"]
        ),
    ]
)
