// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownUI",
	platforms: [
		.macOS(.v15), .iOS(.v18)
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MarkdownUI",
            targets: ["MarkdownUI"]
        ),
    ], dependencies: [
		.package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MarkdownUI",
			dependencies: [
				.product(name: "Markdown", package: "swift-markdown"),
			]
        ),

    ],
    swiftLanguageModes: [.v6]
)
