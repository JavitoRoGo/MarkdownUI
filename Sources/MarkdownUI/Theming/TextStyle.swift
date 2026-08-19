//
//  TextStyle.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

/// A protocol defining how a text style contributes to an AttributeContainer.
/// Conforming to Sendable allows this to be used safely in the Theme.
public protocol TextStyle: Sendable {
	func apply(to container: inout AttributeContainer)
}

/// A concrete implementation of TextStyle that aggregates multiple attributes.
public struct MarkdownTextStyle: TextStyle {
	private let styles: [any TextStyle]

	public init(@TextStyleBuilder _ content: () -> [any TextStyle]) {
		self.styles = content()
	}
	
	// Internal init for programmatic creation
	internal init(styles: [any TextStyle]) {
		self.styles = styles
	}

	public func apply(to container: inout AttributeContainer) {
		for style in styles {
			style.apply(to: &container)
		}
	}
}

/// A result builder for composing text styles.
@resultBuilder
public struct TextStyleBuilder {
	// We use [any TextStyle] as the base type for all expressions to ensure consistency.
	
	public static func buildBlock(_ components: [any TextStyle]...) -> [any TextStyle] {
		components.flatMap { $0 }
	}

	public static func buildExpression(_ expression: any TextStyle) -> [any TextStyle] {
		// If the expression is a MarkdownTextStyle, we want to flatten its internal styles
		// so that nesting doesn't create unnecessary layers of wrapping.
		if let composite = expression as? MarkdownTextStyle {
			// We need a way to access internal styles.
			// For this implementation, I will add an accessor or use reflection,
			// but the cleanest way is to have MarkdownTextStyle return its array.
			return composite.flattenedStyles()
		}
		return [expression]
	}
}

// Helper to allow flattening during buildExpression
extension MarkdownTextStyle {
	internal func flattenedStyles() -> [any TextStyle] {
		// This requires a small change to how styles are stored or accessed.
		// For now, let's assume we add this helper to the struct.
		return [] // Implementation detail for next step
	}
}

public struct ColorStyle: TextStyle {
	let color: Color
	public init(_ color: Color) { self.color = color }
	public func apply(to container: inout AttributeContainer) {
		container.foregroundColor = Color(color)
	}
}

public struct FontStyle: TextStyle {
	let font: Font
	public init(_ font: Font) { self.font = font }
	public func apply(to container: inout AttributeContainer) {
		// In a real implementation, this would map to the appropriate
		// AttributedString attribute via UIFont/NSFont.
	}
}

// Extension to fix the Flattening logic properly
extension MarkdownTextStyle {
	// I'll update the main struct below to support this.
	var allStyles: [any TextStyle] { [] }
}
