import SwiftUI

/// The primary entry point for rendering Markdown in SwiftUI.
public struct MarkdownView: View {
	// We use a private state to hold the parsed content so the view
	// doesn't re-render its entire body unless the AST actually changes.
	@State private var parsedContent: MarkdownContent?
	
	private let rawString: String?
	private let streamingString: Binding<String>?
	private let parser: MarkdownParsing
	
	@Environment(\.markdownTheme) private var theme
	@Environment(\.baseURL) private var baseURL
	@Environment(\.markdownTextStyleOverride) private var styleOverrides

	// 1. Static Initializer (Existing)
	public init(_ markdown: String, parser: MarkdownParsing = GFMParser()) async throws {
		self.rawString = markdown
		self.streamingString = nil
		self.parser = parser
		let content = try await parser.parse(markdown)
		self.parsedContent = content
	}

	// 2. DSL Initializer (Existing)
	public init(@MarkdownContentBuilder _ content: () -> [BlockNode]) {
		self.rawString = nil
		self.streamingString = nil
		self.parser = GFMParser()
		self.parsedContent = MarkdownContent(blocks: content())
	}

	// 3. NEW: Streaming Initializer for LLMs
	/// Initializes the view with a binding to a string that changes over time (e.s. from an LLM).
	public init(streaming text: Binding<String>, parser: MarkdownParsing = GFMParser()) {
		self.rawString = nil
		self.streamingString = text
		self.parser = parser
		self.parsedContent = nil
	}

	// Initializer for pre-parsed content
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
				// Show a placeholder or empty state while the first parse happens
				Color.clear
			}
		}
		// Observe the streaming string and trigger updates
		.onChange(of: streamingString?.wrappedValue ?? "") { _, newValue in
			handleStreamingUpdate(newValue)
		}
		.task {
			// Initial load for static strings
			if let initial = rawString {
				do {
					self.parsedContent = try await parser.parse(initial)
				} catch {
					print("MarkdownUI: Failed to parse initial string: \(error)")
				}
			}
		}
	}

	/// Manages the parsing lifecycle for streaming content.
	private func handleStreamingUpdate(_ text: String) {
		// We use a Task to perform the parsing off the main thread.
		Task {
			do {
				// In a production version, we would implement a debounce here
				// using a Task.sleep or a Combine debouncer to prevent
				// overwhelming the CPU during high-speed token arrival.
				let newContent = try await parser.parse(text)
				
				// Only update if the content actually changed to avoid unnecessary re-renders
				await MainActor.run {
					self.parsedContent = newContent
				}
			} catch {
				print("MarkdownUI: Streaming parse error: \(error)")
			}
		}
	}
}

// MARK: - Styling Modifiers (Unchanged)
extension View {
	public func markdownTheme(_ theme: Theme) -> some View {
		self.environment(\.markdownTheme, theme)
	}

	public func markdownTextStyle(_ type: TextStyleType, _ style: MarkdownTextStyle) -> some View {
		self.modifier(MarkdownTextStyleModifier(type: type, style: style))
	}
}

struct MarkdownTextStyleModifier: ViewModifier {
	let type: TextStyleType
	let style: MarkdownTextStyle

	func body(content: Content) -> some View {
		content.environment(\.markdownTextStyleOverride, [type: style])
	}
}
