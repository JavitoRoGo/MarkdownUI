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
			paragraphStyle: AnyBlockStyle(BlockStyle<Void> { _ in EmptyView() }),
			blockquoteStyle: AnyBlockStyle(BlockStyle<Void> { _ in EmptyView() }),
			listStyle: AnyBlockStyle(BlockStyle<ListMarkerConfiguration> { _ in EmptyView() }),
			codeBlockStyle: AnyBlockStyle(BlockStyle<Void> { _ in EmptyView() }),
			tableStyle: AnyBlockStyle(BlockStyle<Void> { _ in EmptyView() })
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
