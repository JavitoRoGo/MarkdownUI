//
//  AST+DSL.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//

import Foundation

// MARK: - BlockNode DSL Extensions

extension BlockNode {
	/// Creates a heading block with the specified level and inline content.
	///
	/// - Parameters:
	///   - level: The hierarchical level of the heading (e.g., `.h1`).
	///   - content: A closure using `@InlineContentBuilder` to define the text within the heading.
	/// - Returns: A `BlockNode.heading` instance.
	public static func heading(_ level: HeadingLevel, @InlineContentBuilder _ content: () -> [InlineNode]) -> BlockNode {
		.heading(level: level, content())
	}

	/// Creates a paragraph block with the specified inline content.
	///
	/// - Parameter content: A closure using `@InlineContentBuilder` to define the text within the paragraph.
	/// - Returns: A `BlockNode.paragraph` instance.
	public static func paragraph(@InlineContentBuilder _ content: () -> [InlineNode]) -> BlockNode {
		.paragraph(content())
	}

	/// Creates a blockquote block containing nested blocks.
	///
	/// - Parameter content: A closure using `@MarkdownContentBuilder` to define the nested blocks.
	/// - Returns: A `BlockNode.blockquote` instance.
	public static func blockquote(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		.blockquote(content())
	}

	/// Creates a bulleted list where each provided block becomes a single list item.
	///
	/// - Parameter content: A closure using `@MarkdownContentBuilder` to define the items.
	/// - Returns: A `BlockNode.bulletedList` instance.
	public static func bulletedList(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		let items = content().map { ListItem(taskStatus: nil, children: [$0]) }
		return .bulletedList(items)
	}

	/// Creates a numbered list where each provided block becomes a single list item.
	///
	/// - Parameter content: A closure using `@MarkdownContentBuilder` to define the items.
	/// - Returns: A `BlockNode.numberedList` instance.
	public static func numberedList(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		let items = content().map { ListItem(taskStatus: nil, children: [$0]) }
		return .numberedList(items)
	}
	
	/// Creates a task list where each provided block becomes a single list item.
	///
	/// - Parameter content: A closure using `@MarkdownContentBuilder` to define the items.
	/// - Returns: A `BlockNode.taskList` instance.
	public static func taskList(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		let items = content().map { ListItem(taskStatus: nil, children: [$0]) }
		return .taskList(items)
	}

	/// Creates a code block with the provided raw string and an optional language identifier.
	///
	/// - Parameters:
	///   - code: The raw text content of the code block.
	///   - language: An optional string representing the programming language (e.g., "swift").
	/// - Returns: A `BlockNode.codeBlock` instance.
	public static func createCodeBlock(_ code: String, language: String? = nil) -> BlockNode {
		.codeBlock(code, language: language)
	}
}

// MARK: - InlineNode DSL Extensions

extension InlineNode {
	/// Creates a strong emphasis (bold) inline node.
	///
	/// - Parameter content: A closure using `@InlineContentBuilder` to define the text within the emphasis.
	/// - Returns: An `InlineNode.strong` instance.
	public static func strong(@InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.strong(content())
	}

	/// Creates an emphasis (italic) inline node.
	///
	/// - Parameter content: A closure using `@InlineContentBuilder` to define the text within the emphasis.
	/// - Returns: An `InlineNode.emphasis` instance.
	public static func emphasis(@InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.emphasis(content())
	}

	/// Creates a strikethrough inline node.
	///
	/// - Parameter content: A closure using `@InlineContentBuilder` to define the text within the strikethrough.
	/// - Returns: An `InlineNode.strikethrough` instance.
	public static func strikethrough(@InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.strikethrough(content())
	}

	/// Creates a hyperlink inline node.
	///
	/// - Parameters:
	///   - url: The destination `URL` for the link.
	///   - content: A closure using `@InlineContentBuilder` to define the clickable text.
	/// - Returns: An `InlineNode.link` instance.
	public static func link(url: URL, @InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.link(url: url, title: nil, content())
	}

	/// Creates an inline code node with the provided text.
	///
	/// - Parameter text: The raw text to be formatted as code.
	/// - Returns: An `InlineNode.code` instance.
	public static func createCode(_ text: String) -> InlineNode {
		.code(text)
	}
}
