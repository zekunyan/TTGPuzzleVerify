// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TTGPuzzleVerify",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "TTGPuzzleVerify", targets: ["TTGPuzzleVerify"])
    ],
    targets: [
        .target(
            name: "TTGPuzzleVerify",
            path: "TTGPuzzleVerify/Classes",
            publicHeadersPath: "."
        )
    ]
)
