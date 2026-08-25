//
//  GFMBridge.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import Foundation
import cmark_gfm

/// A bridge that translates a GitHub Flavored Markdown (GFM) abstract syntax tree into the native `MarkdownContent` structure.
///
/// `GFMBridge` acts as an intermediary between the low-level C API of the `cmark_gfm` library and the high-level 
/// Swift types used throughout the package. It traverses the tree produced by `cmark_gfm` and maps each node 
/// to its corresponding `BlockNode` or `InlineNode`.
internal struct GFMBridge {
	
	/// Transforms a root `cmark_node` into a structured `MarkdownContent` object.
	///
	/// This method starts at the provided root node and performs a depth-first traversal of the 
	/// entire Markdown tree, converting every C-based node into the package's native AST representation.
	///
	/// - Parameter root: A pointer to the root `cmark_node` produced by the `cmark_gfm` parser.
	/// - Returns: A `MarkdownContent` object containing the fully parsed hierarchy of blocks.
	func transform(root: UnsafeMutablePointer<cmark_node>) -> MarkdownContent {
		var blocks: [BlockNode] = []
		
		var currentChild = cmark_node_first_child(root)
		while let node = currentChild {
			blocks.append(parseBlock(node))
			currentChild = cmark_node_next(node)
		}
		
		return MarkdownContent(blocks: blocks)
	}

	// MARK: - Block Parsing

	/// Parses a single block-level node from the C AST into a `BlockNode`.
	///
	/// This method identifies the type of the node (e.g., heading, paragraph, list, blockquote) 
	/// and recursively parses its children or inline content accordingly.
	///
	/// - Parameter node: The pointer to the `cmark_node` representing a block.
	/// - Returns: A `BlockNode` instance corresponding to the C node's type and content.
	private func parseBlock(_ node: UnsafeMutablePointer<cmark_node>) -> BlockNode {
		let type = cmark_node_get_type(node)

		if type == CMARK_NODE_BLOCK_QUOTE {
			return .blockquote(parseChildren(node))
			
		} else if type == CMARK_NODE_LIST {
			let isOrdered = cmark_node_get_list_type(node) == CMARK_ORDERED_LIST
			let items = parseListItems(node)
			if isTaskList(items) { return .taskList(items) }
			return isOrdered ? .numberedList(items) : .bulletedList(items)
			
		} else if type == CMARK_NODE_HEADING {
			let levelValue = Int(cmark_node_get_heading_level(node))
			let level = BlockNode.HeadingLevel(rawValue: levelValue) ?? .h1
			return .heading(level: level, parseInlines(node))

		} else if type == CMARK_NODE_CODE_BLOCK {
			let content = getString(from: cmark_node_get_literal(node))
			let language = extractLanguage(from: node)
			return .codeBlock(content, language: language)

		} else if type == CMARK_NODE_PARAGRAPH {
			return .paragraph(parseInlines(node))

		} else if type == CMARK_NODE_THEMATIC_BREAK {
			return .thematicBreak

		} else {
			if type == CMARK_NODE_TEXT {
				let text = getString(from: cmark_node_get_literal(node))
				return .paragraph([.text(text)])
			}
			let children = parseChildren(node)
			return children.isEmpty ? .thematicBreak : .paragraph(parseInlines(node)) 
		}
	}

	// MARK: - Inline Parsing

	/// Parses the inline content of a block node.
	///
	/// Iterates through all child nodes of a given block that represent inline elements 
	/// (such as text, emphasis, or links) and converts them into `InlineNode` objects.
	///
	/// - Parameter node: The pointer to the `cmark_node` containing inline children.
	/// - Returns: An array of `InlineNode` instances representing the parsed content.
	private func parseInlines(_ node: UnsafeMutablePointer<cmark_node>) -> [InlineNode] {
		var inlines: [InlineNode] = []
		var currentChild = cmark_node_first_child(node)
		while let child = currentChild {
			inlines.append(parseInline(child))
			currentChild = cmark_node_next(child)
		}
		return inlines
	}

	/// Parses a single inline-level node from the C AST into an `InlineNode`.
	///
	/// - Parameter node: The pointer to the `cmark_node` representing an inline element.
	/// - Returns: An `InlineNode` instance corresponding to the C node's type and content.
	private func parseInline(_ node: UnsafeMutablePointer<cmark_node>) -> InlineNode {
		let type = cmark_node_get_type(node)
		
		switch type {
		case CMARK_NODE_TEXT:
			return .text(getString(from: cmark_node_get_literal(node)))
			
		case CMARK_NODE_STRONG:
			return .strong(parseInlines(node))
			
		case CMARK_NODE_EMPH:
			return .emphasis(parseInlines(node))
			
		case CMARK_NODE_CODE:
			return .code(getString(from: cmark_node_get_literal(node)))

		case CMARK_NODE_LINK:
			let url = extractURL(from: node)
			return .link(url: url, title: nil, parseInlines(node))

		default:
			let children = parseInlines(node)
			return children.first ?? .text("")
		}
	}

	// MARK: - Helpers

	/// Extracts a Swift `String` from a C-style character pointer.
	private func getString(from ptr: UnsafePointer<CChar>?) -> String {
		guard let ptr = ptr else { return "" }
		return String(cString: ptr)
	}

	/// Recursively parses the children of a block node.
	private func parseChildren(_ node: UnsafeMutablePointer<cmark_node>) -> [BlockNode] {
		var nodes: [BlockNode] = []
		var currentChild = cmark_node_first_child(node)
		while let child = currentChild {
			nodes.append(parseBlock(child))
			currentChild = cmark_node_next(child)
		}
		return nodes
	}

	/// Parses the individual items within a list node.
	private func parseListItems(_ node: UnsafeMutablePointer<cmark_node>) -> [ListItem] {
		var items: [ListItem] = []
		var currentChild = cmark_node_first_child(node)
		while let itemNode = currentChild {
			let children = parseChildren(itemNode)
			items.append(ListItem(taskStatus: nil, children: children))
			currentChild = cmark_node_next(itemNode)
		}
		return items
	}

	/// Determines if a list of items should be treated as a task list.
	private func isTaskList(_ items: [ListItem]) -> Bool {
		return false
	}

	/// Extracts the language identifier from a code block node's info string.
	private func extractLanguage(from node: UnsafeMutablePointer<cmark_node>) -> String? {
		guard let info = cmark_node_get_fence_info(node) else { return nil }
		let infoString = String(cString: info)
		return infoString.isEmpty ? nil : infoString
	}

	/// Extracts the URL from a link node.
	private func extractURL(from node: UnsafeMutablePointer<cmark_node>) -> URL {
		guard let urlPtr = cmark_node_get_url(node) else {
			return URL(string: "about:blank")!
		}
		let urlString = String(cString: urlPtr)
		return URL(string: urlString) ?? URL(string: "about:blank")!
	}
}
