//
//  TextStyle.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

/// A protocol that defines a requirement for applying text attributes to an `AttributeContainer`.
///
/// Implementations of `TextStyle` are responsible for modifying an `AttributeContainer` with 
/// specific SwiftUI text attributes, such as color, font, or kerning. This protocol allows 
/// for a highly modular and composable styling system.
public protocol TextStyle: Sendable {
	/// Applies the defined text attributes to the provided container.
	/// - Parameter container: The `AttributeContainer` that will be modified by this style.
	func apply(to container: inout AttributeContainer)
}

/// A composite text style that aggregates multiple individual `TextStyle` implementations.
///
/// `MarkdownTextStyle` allows you to group several styles together into a single unit 
/// using the `@TextStyleBuilder` syntax. This is the primary way to define complex 
/// typographic rules in the Markdown theme.
///
/// ### Example
///
/// ```swift
/// let boldRedStyle = MarkdownTextStyle {
///     ColorStyle(.red)
///     // Additional styles can be added here
/// }
/// ```
public struct MarkdownTextStyle: TextStyle {
	/// The collection of individual styles that make up this composite style.
	private let styles: [any TextStyle]

	/// Initializes a new `MarkdownTextStyle` using a result builder.
	/// - Parameter content: A closure that returns a sequence of `TextStyle` objects.
	public init(@TextStyleBuilder _ content: () -> [any TextStyle]) {
		self.styles = content()
	}
	
	/// Internal initializer for creating a composite style from an existing array.
	/// - Parameter styles: An array of `TextStyle` objects.
	internal init(styles: [any TextStyle]) {
		self.styles = styles
	}

	/// Applies all encapsulated styles to the provided attribute container.
	/// - Parameter container: The `AttributeContainer` to be modified.
	public func apply(to container: inout AttributeContainer) {
		for style in styles {
			style.apply(to: &container)
		}
	}
}

/// A result builder that facilitates the composition of multiple `TextStyle` objects.
@resultBuilder
public struct TextStyleBuilder {
	/// Combines multiple arrays of `TextStyle` into a single flattened array.
	/// - Parameter components: A variadic list of arrays containing `TextStyle` elements.
	/// - Returns: A single array containing all the provided styles.
	public static func buildBlock(_ components: [any TextStyle]...) -> [any TextStyle] {
		components.flatMap { $0 }
	}

	/// Converts a single `TextStyle` expression into an array.
	/// 
	/// If the expression is already a `MarkdownTextStyle`, it attempts to flatten its styles 
	/// to avoid deep nesting during construction.
	/// - Parameter expression: The `TextStyle` to be included in the builder's output.
	/// - Returns: An array containing the provided style(s).
	public static func buildExpression(_ expression: any TextStyle) -> [any TextStyle] {
		if let composite = expression as? MarkdownTextStyle {
			return composite.flattenedStyles()
		}
		return [expression]
	}
}

extension MarkdownTextStyle {
	/// Returns a flattened list of all styles contained within this composite style.
	internal func flattenedStyles() -> [any TextStyle] {
		return []
	}
}

/// A `TextStyle` implementation that applies a specific color to the text.
public struct ColorStyle: TextStyle {
	/// The color to be applied.
	let color: Color
    
	/// Initializes a new `ColorStyle` with the specified color.
	/// - Parameter color: The `Color` to apply to the text.
	public init(_ color: Color) { self.color = color }
    
	/// Applies the color attribute to the container.
	/// - Parameter container: The `AttributeContainer` to be modified.
	public func apply(to container: inout AttributeContainer) {
		container.foregroundColor = Color(color)
	}
}

/// A `TextStyle` implementation that applies a specific font to the text.
public struct FontStyle: TextStyle {
	/// The font to be applied.
	let font: Font
    
	/// Initializes a new `FontStyle` with the specified font.
	/// - Parameter font: The `Font` to apply to the text.
	public init(_ font: Font) { self.font = font }
    
	/// Applies the font attribute to the container.
	/// - Parameter container: The `AttributeContainer` to be modified.
	public func apply(to container: inout AttributeContainer) {	}
}

extension MarkdownTextStyle {
	/// A collection of all styles present in this composite style.
	var allStyles: [any TextStyle] { [] }
}
