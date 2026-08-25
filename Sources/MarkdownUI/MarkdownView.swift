import SwiftUI

/// The primary view for rendering Markdown content in a SwiftUI application.
///
/// `MarkdownView` provides several ways to display Markdown, depending on the source of your data:
/// - **Static Markdown**: Initialize with a simple `String`.
/// - **Dynamic/Streaming Markdown**: Initialize with a `Binding<String>` to automatically re-parse content as it changes (ideal for LLM responses).
/// - **Declarative AST**: Initialize using the `@MarkdownContentBuilder` DSL to build the document structure manually.
/// - **Pre-parsed Content**: Initialize directly with a `MarkdownContent` object.
///
/// This view automatically handles asynchronous parsing and integrates deeply with the 
/// `Theme` system via SwiftUI Environment values.
public struct MarkdownView: View {
	@State private var parsedContent: MarkdownContent?
	
	private let rawString: String?
	private let streamingString: Binding<String>?
	private let parser: MarkdownParsing
	
	@Environment(\.markdownTheme) private var theme
	@Environment(\.baseURL) private var baseURL
	@Environment(\.markdownTextStyleOverride) private var styleOverrides

	/// Initializes a `MarkdownView` with a static Markdown string.
	/// - Parameters:
	///   - markdown: The raw Markdown text to be parsed.
	///   - parser: The engine used to parse the text. Defaults to `GFMParser`.
	public init(_ markdown: String, parser: MarkdownParsing = GFMParser()) {
		self.rawString = markdown
		self.streamingString = nil
		self.parser = parser
		self.parsedContent = nil
	}

	/// Initializes a `MarkdownView` using the declarative DSL to construct an AST.
	///
	/// This is useful when you want to build a Markdown document programmatically 
	/// without writing raw strings.
	///
	/// ### Example
	/// ```swift
	/// MarkdownView {
	///     BlockNode.heading(.h1) {
	///         "Hello DSL"
	///     }
	/// }
	/// ```
	/// - Parameter content: A closure using `@MarkdownContentBuilder` to define the document structure.
	public init(@MarkdownContentBuilder _ content: () -> [BlockNode]) {
		self.rawString = nil
		self.streamingString = nil
		self.parser = GFMParser()
		self.parsedContent = MarkdownContent(blocks: content())
	}

	/// Initializes a `MarkdownView` that observes a binding for streaming content.
	///
	/// Use this initializer when the Markdown text is being updated incrementally, 
	/// such as during a live chat session with an AI. The view will automatically 
	/// re-parse the content whenever the binding changes.
	///
	/// - Parameters:
	///   - text: A `Binding` to the string currently being streamed.
	///   - parser: The engine used to parse the text. Defaults to `GFMParser`.
	public init(streaming text: Binding<String>, parser: MarkdownParsing = GFMParser()) {
		self.rawString = nil
		self.streamingString = text
		self.parser = parser
		self.parsedContent = nil
	}

	/// Initializes a `MarkdownView` with already parsed content.
	/// - Parameter content: A `MarkdownContent` object representing the AST.
	public init(content: MarkdownContent) {
		self.rawString = nil
		self.streamingString = nil
		self.parser = GFMParser()
		self.parsedContent = content
	}

	public var body: some View {
		Group {
			if let content = parsedContent {
				BlockSequence(blocks: content.blocks)
					.environment(\.baseURL, baseURL)
					.environment(\.markdownTextStyleOverride, styleOverrides)
			} else {
				ContentUnavailableView("Cargando...", systemImage: "magnifyingglass")
			}
		}
		.onChange(of: streamingString?.wrappedValue ?? "") { _, newValue in
			handleStreamingUpdate(newValue)
		}
		.task {
			if let initial = rawString {
				await performParse(initial)
			} else if let initialStreamingValue = streamingString?.wrappedValue, !initialStreamingValue.isEmpty {
				await performParse(initialStreamingValue)
			}
		}
	}

	/// Performs the asynchronous parsing of the text using the provided parser.
	/// - Parameter text: The raw string to parse.
	private func performParse(_ text: String) async {
		do {
			let content = try await parser.parse(text)
			await MainActor.run {
				self.parsedContent = content
			}
		} catch {
			print("MarkdownUI: Parse error: \(error)")
		}
	}

	/// Handles updates when the streaming string changes.
	/// - Parameter text: The updated string value.
	private func handleStreamingUpdate(_ text: String) {
		Task {
			await performParse(text)
		}
	}
}

// MARK: - Styling Modifiers

extension View {
	/// Applies a custom `Theme` to the Markdown rendering within this view and its children.
	/// - Parameter theme: The theme configuration to apply.
	/// - Returns: A view with the specified environment theme.
	public func markdownTheme(_ theme: Theme) -> some View {
		self.environment(\.markdownTheme, theme)
	}

	/// Overrides a specific inline text style for all Markdown content within this view.
	///
	/// This is useful for making subtle changes (like changing only the color of links) 
	/// without redefining the entire `Theme`.
	///
	/// ### Example
	/// ```swift
	/// MarkdownView(myString)
	///     .markdownTextStyle(.link, MarkdownTextStyle { ColorStyle(.blue) })
	/// ```
	/// - Parameters:
	///   - type: The `TextStyleType` to override (e.g., `.strong`, `.link`).
	///   - style: The new `MarkdownTextStyle` to apply.
	/// - Returns: A view with the specific style override in its environment.
	public func markdownTextStyle(_ type: TextStyleType, _ style: MarkdownTextStyle) -> some View {
		self.modifier(MarkdownTextStyleModifier(type: type, style: style))
	}
}

/// A private modifier that injects a single text style override into the environment.
struct MarkdownTextStyleModifier: ViewModifier {
	let type: TextStyleType
	let style: MarkdownTextStyle

	func body(content: Content) -> some View {
		content.environment(\.markdownTextStyleOverride, [type: style])
	}
}
