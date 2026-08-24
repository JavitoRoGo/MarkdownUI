//
//  TextStyle.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

public protocol TextStyle: Sendable {
	func apply(to container: inout AttributeContainer)
}

public struct MarkdownTextStyle: TextStyle {
	private let styles: [any TextStyle]

	public init(@TextStyleBuilder _ content: () -> [any TextStyle]) {
		self.styles = content()
	}
	
	internal init(styles: [any TextStyle]) {
		self.styles = styles
	}

	public func apply(to container: inout AttributeContainer) {
		for style in styles {
			style.apply(to: &container)
		}
	}
}

@resultBuilder
public struct TextStyleBuilder {
	public static func buildBlock(_ components: [any TextStyle]...) -> [any TextStyle] {
		components.flatMap { $0 }
	}

	public static func buildExpression(_ expression: any TextStyle) -> [any TextStyle] {
		if let composite = expression as? MarkdownTextStyle {
			return composite.flattenedStyles()
		}
		return [expression]
	}
}

extension MarkdownTextStyle {
	internal func flattenedStyles() -> [any TextStyle] {
		return []
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
	public func apply(to container: inout AttributeContainer) {	}
}

extension MarkdownTextStyle {
	var allStyles: [any TextStyle] { [] }
}
