//
//  AST+DSL.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//

import Foundation

// MARK: - BlockNode DSL Extensions

extension BlockNode {
	public static func heading(_ level: HeadingLevel, @InlineContentBuilder _ content: () -> [InlineNode]) -> BlockNode {
		.heading(level: level, content())
	}

	public static func paragraph(@InlineContentBuilder _ content: () -> [InlineNode]) -> BlockNode {
		.paragraph(content())
	}

	public static func blockquote(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		.blockquote(content())
	}

	public static func bulletedList(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		let items = content().map { ListItem(taskStatus: nil, children: [$0]) }
		return .bulletedList(items)
	}

	public static func numberedList(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		let items = content().map { ListItem(taskStatus: nil, children: [$0]) }
		return .numberedList(items)
	}
	
	public static func taskList(@MarkdownContentBuilder _ content: () -> [BlockNode]) -> BlockNode {
		let items = content().map { ListItem(taskStatus: nil, children: [$0]) }
		return .taskList(items)
	}

	public static func createCodeBlock(_ code: String, language: String? = nil) -> BlockNode {
		.codeBlock(code, language: language)
	}
}

// MARK: - InlineNode DSL Extensions

extension InlineNode {
	public static func strong(@InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.strong(content())
	}

	public static func emphasis(@InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.emphasis(content())
	}

	public static func strikethrough(@InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.strikethrough(content())
	}

	public static func link(url: URL, @InlineContentBuilder _ content: () -> [InlineNode]) -> InlineNode {
		.link(url: url, title: nil, content())
	}

	public static func createCode(_ text: String) -> InlineNode {
		.code(text)
	}
}
