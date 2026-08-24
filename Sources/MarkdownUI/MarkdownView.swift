import SwiftUI

public struct MarkdownView: View {
	@State private var parsedContent: MarkdownContent?
	
	private let rawString: String?
	private let streamingString: Binding<String>?
	private let parser: MarkdownParsing
	
	@Environment(\.markdownTheme) private var theme
	@Environment(\.baseURL) private var baseURL
	@Environment(\.markdownTextStyleOverride) private var styleOverrides

	public init(_ markdown: String, parser: MarkdownParsing = GFMParser()) {
		self.rawString = markdown
		self.streamingString = nil
		self.parser = parser
		self.parsedContent = nil
	}

	public init(@MarkdownContentBuilder _ content: () -> [BlockNode]) {
		self.rawString = nil
		self.streamingString = nil
		self.parser = GFMParser()
		self.parsedContent = MarkdownContent(blocks: content())
	}

	public init(streaming text: Binding<String>, parser: MarkdownParsing = GFMParser()) {
		self.rawString = nil
		self.streamingString = text
		self.parser = parser
		self.parsedContent = nil
	}

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

	private func handleStreamingUpdate(_ text: String) {
		Task {
			await performParse(text)
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
