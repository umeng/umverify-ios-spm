// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "UMVerify",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "UMVerify", targets: ["UMVerify", "UMVerifyShim"]),
    ],
    dependencies: [
        .package(url: "https://github.com/umeng/umcommon-ios-spm.git", exact: "7.7.0"),
    ],
    targets: [
        // UMVerify.framework is a static library that already has the Aliyun
        // ATAuthSDK (一键登录) statically merged in, so consumers do NOT need to
        // add ATAuthSDK separately.
        .binaryTarget(
            name: "UMVerify",
            path: "UMVerify.xcframework"
        ),
        // Aliyun cloud-communication components that UMVerify hard-links against
        // (undefined symbols ACMManager / YTXVendorService / YTXNetUtils). ATAuth
        // is already merged into UMVerify, but YTXMonitor/YTXOperators ship as
        // separate static xcframeworks. Sourced from the upstream standard-UI
        // cloud SDK v2.14.18 (sdk_code/UMVerify/YTX_SDK). Only the standard-UI
        // variant is published via SPM; NUI/UIL variants are offline-only.
        .binaryTarget(
            name: "YTXMonitor",
            path: "YTXMonitor.xcframework"
        ),
        .binaryTarget(
            name: "YTXOperators",
            path: "YTXOperators.xcframework"
        ),
        // Shim target: carries the resource bundle, system link flags and the
        // UMCommon dependency that a binary target cannot declare itself.
        .target(
            name: "UMVerifyShim",
            dependencies: [
                "UMVerify",
                "YTXMonitor",
                "YTXOperators",
                .product(name: "UMCommon", package: "umcommon-ios-spm"),
            ],
            path: "Sources/UMVerifyShim",
            resources: [
                .copy("ATAuthSDK.bundle"),
            ],
            linkerSettings: [
                // UMVerify itself
                .linkedFramework("Security"),
                .linkedLibrary("sqlite3"),
                .linkedLibrary("z"),
                // ATAuthSDK (阿里云号码认证) requirements
                .linkedFramework("CoreTelephony"),
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("WebKit"),
                .linkedLibrary("c++"),
            ]
        ),
    ]
)
