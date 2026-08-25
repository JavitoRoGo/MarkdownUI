//
//  Theme.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// A configuration object that defines the visual appearance of all Markdown elements.
///
/// `Theme` centralizes the styling rules for both inline text components (like bold or links)
/// and block-level components (like headings, paragraphs, or lists). By providing a custom 
/// `Theme`, you can completely redefine how your Markdown content is rendered to match 
/// your application's design language.
public struct Theme: Sendable {
	/// The style applied to standard text.
	public var textStyle: MarkdownTextStyle
    
	/// The style applied to text within a strong (bold) emphasis.
	public var strongStyle: MarkdownTextStyle
    
	/// The style applied to text within an emphasis (italic) element.
	public var emphasisStyle: MarkdownTextStyle
    
	/// The style applied to text within a hyperlink.
	public var linkStyle: MarkdownTextStyle
    
	/// The style applied to text within inline code segments.
	public var codeStyle: MarkdownTextStyle
	
	/// A dictionary mapping heading levels (1-6) to their respective block styles.
	public var headingStyle: [Int: AnyBlockStyle]
    
	/// The style applied to standard paragraph blocks.
	public var paragraphStyle: AnyBlockStyle
    
	/// The style applied to blockquote elements.
	public var blockquoteStyle: AnyBlockStyle
    
	/// The style applied to lists (bulleted, numbered, or task lists).
	public var listStyle: AnyBlockStyle
    
	/// The style applied to multi-line code blocks.
	public var codeBlockStyle: AnyBlockStyle
    
	/// The style applied to Markdown tables.
	public var tableStyle: AnyBlockStyle

	/// The default theme provided by the package.
	///
	/// This theme provides a neutral, standard appearance that follows common 
	/// Markdown rendering conventions.
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

/// A configuration used to define the visual markers (bullets, numbers, etc.) for list items.
public struct ListMarkerConfiguration: Sendable {
	/// A closure that returns a view representing the bullet marker.
	public let bullet: @Sendable () -> AnyView
    
	/// A closure that returns a view representing the numbered marker.
	public let number: @Sendable () -> AnyView
}

// MARK: - Environment Integration

private struct MarkdownThemeKey: EnvironmentKey {
	static let defaultValue: Theme = .default
}

extension EnvironmentValues {
	/// The current `Theme` used for rendering Markdown content in the view hierarchy.
    ///
    /// Use this property to inject a custom theme into your Markdown views.
    ///
    /// ```swift
    /// MarkdownContent(blocks)
    ///     .markdownTheme(myCustomTheme)
    /// ```
	public var markdownTheme: Theme {
		get { self[MarkdownThemeKey.self] }
		set { self[MarkdownThemeKey.self] = newValue }
	}
}

private struct TightSpacingKey: EnvironmentKey {
	static let defaultValue: Bool = true
}

extension EnvironmentValues {
	/// A Boolean value indicating whether to use compact spacing between block elements.
    ///
    /// When `true`, a reduced spacing is used between blocks, making the document more dense.
    /// When `false`, a more spacious layout is applied.
	public var tightSpacingEnabled: Bool {
		get { self[TightSpacingKey.self] }
		set { self[TightSpacingKey.self] = newValue }
	}
}

private struct BaseURLKey: EnvironmentKey {
	static let defaultValue: URL? = nil
}

extension EnvironmentValues {
	/// The base URL used to resolve relative paths in links or images within the Markdown content.
	public var baseURL: URL? {
		get { self[BaseURLKey.self] }
		set { self[BaseURLKey.self] = newValue }
	}
}

private struct MarkdownOverrideTextStyleKey: EnvironmentKey {
	static let defaultValue: [TextStyleType: MarkdownTextStyle] = [:]
}

/// Identifies the specific types of inline text styles that can be overridden.
public enum TextStyleType: Hashable, Sendable {
	case strong
	case emphasis
	case link
	case code
}

extension EnvironmentValues {
	/// A dictionary of style overrides for specific inline text elements.
    ///
    /// This allows you to override only certain parts of the theme (like making all links blue) 
    /// without needing to redefine the entire `Theme` object.
	public var markdownTextStyleOverride: [TextStyleType: MarkdownTextStyle] {
		get { self[MarkdownOverrideTextStyleKey.self] }
		set { self[MarkdownOverrideTextStyleKey.self] = newValue }
	}
}
