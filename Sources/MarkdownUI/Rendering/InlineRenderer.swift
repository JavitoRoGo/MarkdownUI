//
//  InlineRenderer.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

struct InlineRenderer {
	let theme: Theme
	let baseURL: URL?
	let styleOverrides: [TextStyleType: MarkdownTextStyle]

	init(theme: Theme, baseURL: URL? = nil, styleOverrides: [TextStyleType: MarkdownTextStyle] = [:]) {
		self.theme = theme
		self.baseURL = baseURL
		self.styleOverrides = styleOverrides
	}

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
			applyPresentationIntent(.stronglyEmphasized, to: &attributed)
			let style = styleOverrides[.strong] ?? theme.strongStyle
			applyStyle(style, to: &attributed)
			return attributed

		case .emphasis(let children):
			var attributed = render(children)
			applyPresentationIntent(.emphasized, to: &attributed)
			let style = styleOverrides[.emphasis] ?? theme.emphasisStyle
			applyStyle(style, to: &attributed)
			return attributed

		case .strikethrough(let children):
			let attributed = render(children)
			return attributed

		case .code(let text):
			var attributed = AttributedString(text)
			let style = styleOverrides[.code] ?? theme.codeStyle
			applyStyle(style, to: &attributed)
			return attributed

		case .link(let url, _, let children):
			var attributed = render(children)
			if let baseURL = baseURL {
				attributed.link = baseURL.appendingPathComponent(url.absoluteString)
			} else {
				attributed.link = url
			}
			return attributed

		case .image(let url, let altText, _):
			let finalURL = baseURL?.appendingPathComponent(url.absoluteString) ?? url
			return AttributedString("[\(altText)](\(finalURL.absoluteString))")

		case .html(let html):
			return AttributedString(html)
		}
	}

	private func applyStyle(_ style: MarkdownTextStyle, to attributedString: inout AttributedString) {
		var container = AttributeContainer()
		style.apply(to: &container)
		attributedString.mergeAttributes(container)
	}
	
	private func applyPresentationIntent(_ intent: InlinePresentationIntent, to attributedString: inout AttributedString) {
			for run in attributedString.runs {
				var combinedIntent = run.inlinePresentationIntent ?? []
				combinedIntent.insert(intent)
				attributedString[run.range].inlinePresentationIntent = combinedIntent
			}
		}
}
