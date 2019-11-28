// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "Convoy",
  products: [
    .library(name: "Convoy", targets: ["Convoy"]),
    .library(name: "RxConvoy", targets: ["RxConvoy"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift", from: "5.0.0")
  ],
  targets: [
    .target(name: "Convoy", dependencies: []),
    .target(name: "RxConvoy", dependencies: ["Convoy", "RxSwift"]),
    .testTarget(name: "ConvoyTests", dependencies: ["Convoy"]),
    .testTarget(name: "RxConvoyTests", dependencies: ["RxConvoy", "Convoy"]),
  ]
)
