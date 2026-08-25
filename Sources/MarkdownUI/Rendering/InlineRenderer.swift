import SwiftUI

/// A renderer that converts a sequence of inline Markdown nodes into a single, styled `AttributedString`.
///
/// `InlineRenderer` is responsible for processing all text-level formatting within the Markdown document. 
/// It traverses the hierarchy of `InlineNode` objects and applies appropriate attributes (such as 
/// font weight, color, or links) based on the provided `Theme` and any specific style overrides.
///
/// This renderer utilizes SwiftUI's `AttributedString` to ensure high-performance text rendering 
/// and seamless integration with modern SwiftUI components.
struct InlineRenderer {
	/// The theme containing default styles for inline elements.
	let theme: Theme
	/// An optional base URL used to resolve relative paths in links or images.
	let baseURL: URL?
	/// A dictionary of specific style overrides for different text types.
	let styleOverrides: [TextStyleType: MarkdownTextStyle]

	/// Creates a new `InlineRenderer`.
	/// - Parameters:
	///   - theme: The `Theme` to use for default inline styling.
	///   - baseURL: An optional base URL for resolving relative URLs. Defaults to `nil`.
	///   - styleOverrides: A dictionary providing specific `MarkdownTextStyle` overrides. Defaults to an empty dictionary.
	init(theme: Theme, baseURL: URL? = nil, styleOverrides: [TextStyleType: MarkdownTextStyle] = [:]) {
		self.theme = theme
		self.baseURL = baseURL
		self.styleOverrides = styleOverrides
	}

	/// Renders a sequence of `InlineNode`s into an `AttributedString`.
	///
	/// This method iterates through all provided nodes, renders each one individually, 
	/// and combines them into a single cohesive attributed string.
	///
	/// - Parameter nodes: The array of `InlineNode` objects to be rendered.
	/// - Returns: An `AttributedString` representing the styled inline content.
	func render(_ nodes: [InlineNode]) -> AttributedString {
		var combinedString = AttributedString()
		
		for node in nodes {
			let renderedNode = render(node)
			combinedString.append(renderedNode)
		}
		
		return combinedString
	}

	/// Recursively renders a single `InlineNode` into an `AttributedString`.
	///
	/// This method handles the conversion of specific node types (like `.strong`, `.emphasis`, 
	/// or `.link`) by applying the corresponding attributes from the theme or overrides.
	///
	/// - Parameter node: The individual `InlineNode` to render.
	/// - Returns: An `AttributedString` representing the styled node.
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

	/// Applies a `MarkdownTextStyle` to the provided attributed string.
	///
	/// - Parameters:
	///   - style: The style containing the attributes to apply.
	///   - attributedString: The string to which the style will be merged.
	private func applyStyle(_ style: MarkdownTextStyle, to attributedString: inout AttributedString) {
		var container = AttributeContainer()
		style.apply(to: &container)
		attributedString.mergeAttributes(container)
	}
	
	/// Applies a semantic `InlinePresentationIntent` to the provided attributed string.
	///
	/// This allows SwiftUI to understand the purpose of certain text runs (for example, 
	/// providing better context for accessibility services).
	///
	/// - Parameters:
	///   - intent: The presentation intent to insert.
	///   - attributedString: The string to modify.
	private func applyPresentationIntent(_ intent: InlinePresentationIntent, to attributedString: inout AttributedString) {
			for run in attributedString.runs {
				var combinedIntent = run.inlinePresentationIntent ?? []
				combinedIntent.insert(intent)
				attributedString[run.range].inlinePresentationIntent = combinedIntent
			}
		}
}
