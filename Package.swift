// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MarkdownUI",
	platforms: [
		.macOS(.v15), .iOS(.v18)
	],
    products: [
        .library(
            name: "MarkdownUI",
            targets: ["MarkdownUI"]
        ),
    ], dependencies: [
		.package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
	],
    targets: [
        .target(
            name: "MarkdownUI",
			dependencies: [
				.product(name: "Markdown", package: "swift-markdown"),
			]
        ),

    ],
    swiftLanguageModes: [.v6]
)
