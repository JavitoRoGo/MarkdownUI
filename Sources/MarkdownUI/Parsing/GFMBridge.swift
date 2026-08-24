import Foundation
import cmark_gfm

internal struct GFMBridge {
	
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

	private func parseInlines(_ node: UnsafeMutablePointer<cmark_node>) -> [InlineNode] {
		var inlines: [InlineNode] = []
		var currentChild = cmark_node_first_child(node)
		while let child = currentChild {
			inlines.append(parseInline(child))
			currentChild = cmark_node_next(child)
		}
		return inlines
	}

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

	private func getString(from ptr: UnsafePointer<CChar>?) -> String {
		guard let ptr = ptr else { return "" }
		return String(cString: ptr)
	}

	private func parseChildren(_ node: UnsafeMutablePointer<cmark_node>) -> [BlockNode] {
		var nodes: [BlockNode] = []
		var currentChild = cmark_node_first_child(node)
		while let child = currentChild {
			nodes.append(parseBlock(child))
			currentChild = cmark_node_next(child)
		}
		return nodes
	}

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

	private func isTaskList(_ items: [ListItem]) -> Bool {
		return false
	}

	private func extractLanguage(from node: UnsafeMutablePointer<cmark_node>) -> String? {
		guard let info = cmark_node_get_fence_info(node) else { return nil }
		let infoString = String(cString: info)
		return infoString.isEmpty ? nil : infoString
	}

	private func extractURL(from node: UnsafeMutablePointer<cmark_node>) -> URL {
		guard let urlPtr = cmark_node_get_url(node) else {
			return URL(string: "about:blank")!
		}
		let urlString = String(cString: urlPtr)
		return URL(string: urlString) ?? URL(string: "about:blank")!
	}
}
