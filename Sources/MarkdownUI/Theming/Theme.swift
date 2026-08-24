//
//  Theme.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

public struct ListMarkerConfiguration: Sendable {
	public let bullet: @Sendable () -> AnyView
	public let number: @Sendable () -> AnyView
}

public struct Theme: Sendable {
	public var textStyle: MarkdownTextStyle
	public var strongStyle: MarkdownTextStyle
	public var emphasisStyle: MarkdownTextStyle
	public var linkStyle: MarkdownTextStyle
	public var codeStyle: MarkdownTextStyle
	
	public var headingStyle: [Int: AnyBlockStyle]
	public var paragraphStyle: AnyBlockStyle
	public var blockquoteStyle: AnyBlockStyle
	public var listStyle: AnyBlockStyle
	public var codeBlockStyle: AnyBlockStyle
	public var tableStyle: AnyBlockStyle

	public static let `default`: Theme = {
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

private struct TightSpacingKey: EnvironmentKey {
	static let defaultValue: Bool = true
}

extension EnvironmentValues {
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

private struct MarkdownOverrideTextStyleKey: EnvironmentKey {
	static let defaultValue: [TextStyleType: MarkdownTextStyle] = [:]
}

public enum TextStyleType: Hashable, Sendable {
	case strong
	case emphasis
	case link
	case code
}

extension EnvironmentValues {
	public var markdownTextStyleOverride: [TextStyleType: MarkdownTextStyle] {
		get { self[MarkdownOverrideTextStyleKey.self] }
		set { self[MarkdownOverrideTextStyleKey.self] = newValue }
	}
}
