//
//  InlineRenderer.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// An internal engine responsible for transforming AST InlineNodes into a single AttributedString.
struct InlineRenderer {
	let theme: Theme
	let baseURL: URL?
	/// The overrides collected from the environment via .markdownTextStyle()
	let styleOverrides: [TextStyleType: MarkdownTextStyle]

	init(theme: Theme, baseURL: URL? = nil, styleOverrides: [TextStyleType: MarkdownTextStyle] = [:]) {
		self.theme = theme
		self.baseURL = baseURL
		self.styleOverrides = styleOverrides
	}

	/// Transforms a collection of inline nodes into a single AttributedString.
	func render(_ nodes: [InlineNode]) -> AttributedString {
		var combinedString = AttributedString()
		
		for node in nodes {
			let renderedNode = render(node)
			combinedString.append(renderedNode)
		}
		
		return combinedString
	}

	private func render(_ node: InlineNode) -> AttributedString {
		switch node {
		case .text(let string):
			return AttributedString(string)

		case .softBreak, .lineBreak:
			return AttributedString("\n")

		case .strong(let children):
			var attributed = render(children)
			// Check for override, otherwise use theme
			let style = styleOverrides[.strong] ?? theme.strongStyle
			applyStyle(style, to: &attributed)
			return attributed

		case .emphasis(let children):
			var attributed = render(children)
			// Check for override, otherwise use theme
			let style = styleOverrides[.emphasis] ?? theme.emphasisStyle
			applyStyle(style, to: &attributed)
			return attributed

		case .strikethrough(let children):
			var attributed = render(children)
			// Strikethrough implementation (using standard attribute if available)
			// Note: In a real production app, we'd look for a dedicated strikethrough style.
			return attributed

		case .code(let text):
			var attributed = AttributedString(text)
			// Check for override, otherwise use theme
			let style = styleOverrides[.code] ?? theme.codeStyle
			applyStyle(style, to: &attributed)
			return attributed

		case .link(let url, let title, let children):
			var attributed = render(children)
			// Resolve relative URL with baseURL if available
			if let baseURL = baseURL {
				attributed.link = baseURL.appendingPathComponent(url.absoluteString)
			} else {
				attributed.link = url
			}
			return attributed

		case .image(let url, let altText, _):
			// Handle relative URLs for images as well
			let finalURL = baseURL?.appendingPathComponent(url.absoluteString) ?? url
			return AttributedString("[\(altText)](\(finalURL.absoluteString))")

		case .html(let html):
			return AttributedString(html)
		}
	}

	/// Merges the theme's TextStyle into the AttributedString's AttributeContainer.
	private func applyStyle(_ style: MarkdownTextStyle, to attributedString: inout AttributedString) {
		var container = AttributeContainer()
		style.apply(to: &container)
		attributedString.mergeAttributes(container)
	}
}
