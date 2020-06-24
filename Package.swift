// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AEPCore-Package",
    platforms: [
        .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
        name: "AEPServices",
        targets: ["AEPServices"]),
        
        .library(
        name: "AEPCore",
        targets: [ "AEPCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AEPServices",
            dependencies: [],
            path: "./Packages/AEPServices/Sources"
        ),
        .target(
            name: "AEPCore",
            dependencies: ["AEPServices"],
            path: "./Packages/AEPCore/Sources"
        ),
//        .testTarget(
//            name: "AEPConfigurationTests",
//            dependencies: ["AEPConfiguration"]),
    ]
)
