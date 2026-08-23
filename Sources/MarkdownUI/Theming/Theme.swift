//
//  Theme.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// Configuration for list markers (bullets, numbers, tasks).
public struct ListMarkerConfiguration: Sendable {
	public let bullet: @Sendable () -> AnyView
	public let number: @Sendable () -> AnyView
}

/// The master object defining the look and feel of MarkdownUI.
public struct Theme: Sendable {
	// Inline Styles
	public var textStyle: MarkdownTextStyle
	public var strongStyle: MarkdownTextStyle
	public var emphasisStyle: MarkdownTextStyle
	public var linkStyle: MarkdownTextStyle
	public var codeStyle: MarkdownTextStyle
	
	// Block Styles (Type-erased)
	public var headingStyle: [Int: AnyBlockStyle]
	public var paragraphStyle: AnyBlockStyle
	public var blockquoteStyle: AnyBlockStyle
	public var listStyle: AnyBlockStyle
	public var codeBlockStyle: AnyBlockStyle
	public var tableStyle: AnyBlockStyle

	public static let `default`: Theme = {
		// For now, a placeholder that complies with Sendable requirements.
		// In reality, this will return the full default theme.
		Theme(
			textStyle: MarkdownTextStyle { },
			strongStyle: MarkdownTextStyle { },
			emphasisStyle: MarkdownTextStyle { },
			linkStyle: MarkdownTextStyle { },
			codeStyle: MarkdownTextStyle { },
			headingStyle: [:],
			paragraphStyle: AnyBlockStyle(BlockStyle<Void> { _, content in content }),
			blockquoteStyle: AnyBlockStyle(BlockStyle<Void> { _, content in content }),
			listStyle: AnyBlockStyle(BlockStyle<ListMarkerConfiguration> { _, content in content }),
			codeBlockStyle: AnyBlockStyle(BlockStyle<Void> { _, content in content }),
			tableStyle: AnyBlockStyle(BlockStyle<Void> { _, content in content })
		)
	}()
}

// MARK: - Environment Integration

private struct MarkdownThemeKey: EnvironmentKey {
	static let defaultValue: Theme = .default
}

extension EnvironmentValues {
	public var markdownTheme: Theme {
		get { self[MarkdownThemeKey.self] }
		set { self[MarkdownThemeKey.self] = newValue }
	}
}

/// A key for controlling whether block elements should use tight spacing
/// or standard spacing within the Markdown renderer.
private struct TightSpacingKey: EnvironmentKey {
	/// The default value when no value is provided in the environment.
	static let defaultValue: Bool = true
}

extension EnvironmentValues {
	/// A user-controlled value to toggle between tight and loose vertical spacing
	/// for block elements in MarkdownUI.
	public var tightSpacingEnabled: Bool {
		get { self[TightSpacingKey.self] }
		set { self[TightSpacingKey.self] = newValue }
	}
}

private struct BaseURLKey: EnvironmentKey {
	static let defaultValue: URL? = nil
}

extension EnvironmentValues {
	public var baseURL: URL? {
		get { self[BaseURLKey.self] }
		set { self[BaseURLKey.self] = newValue }
	}
}

/// An internal key to allow overriding specific text styles within a view hierarchy.
private struct MarkdownOverrideTextStyleKey: EnvironmentKey {
	static let defaultValue: [TextStyleType: MarkdownTextStyle] = [:]
}

/// Defines the types of inline elements that can be overridden.
public enum TextStyleType: Hashable, Sendable {
	case strong
	case emphasis
	case link
	case code
}

extension EnvironmentValues {
	/// Allows overriding specific inline text styles within a sub-hierarchy.
	public var markdownTextStyleOverride: [TextStyleType: MarkdownTextStyle] {
		get { self[MarkdownOverrideTextStyleKey.self] }
		set { self[MarkdownOverrideTextStyleKey.self] = newValue }
	}
}
