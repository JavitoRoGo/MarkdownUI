//
//  MarkdownView.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//

import SwiftUI

/// The primary entry point for rendering Markdown in SwiftUI.
public struct MarkdownView: View {
	private let content: MarkdownContent
	@Environment(\.markdownTheme) private var theme
	@Environment(\.baseURL) private var baseURL
	@Environment(\.markdownTextStyleOverride) private var styleOverrides

	// Initializer for raw String (Parses on initialization)
	public init(_ markdown: String, parser: MarkdownParsing = GFMParser()) async throws {
		let parsedContent = try await parser.parse(markdown)
		self.content = parsedContent
	}

	// Initializer for pre-parsed MarkdownContent
	public init(content: MarkdownContent) {
		self.content = content
	}

	// Initializer for the DSL (@MarkdownContentBuilder)
	public init(@MarkdownContentBuilder _ content: () -> [BlockNode]) {
		self.content = MarkdownContent(blocks: content())
	}

	public var body: some View {
		BlockSequence(blocks: content.blocks)
			.environment(\.baseURL, baseURL)
			// We must pass the styleOverrides down to the BlockSequence
			// so the InlineRenderer can access them.
			.environment(\.markdownTextStyleOverride, styleOverrides)
	}
}

// MARK: - Styling Modifiers

extension View {
	/// Applies a custom theme to all Markdown elements within this view hierarchy.
	public func markdownTheme(_ theme: Theme) -> some View {
		self.environment(\.markdownTheme, theme)
	}

	/// Overrides a specific inline text style for the provided sub-hierarchy.
	public func markdownTextStyle(_ type: TextStyleType, _ style: MarkdownTextStyle) -> some View {
		self.modifier(MarkdownTextStyleModifier(type: type, style: style))
	}
}

/// Internal helper to update the environment dictionary for text overrides.
struct MarkdownTextStyleModifier: ViewModifier {
	let type: TextStyleType
	let style: MarkdownTextStyle

	func body(content: Content) -> some View {
		content.environment(\.markdownTextStyleOverride, [type: style])
	}
}
