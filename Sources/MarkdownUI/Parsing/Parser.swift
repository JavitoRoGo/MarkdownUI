import Foundation
import cmark_gfm

public protocol MarkdownParsing: Sendable {
	func parse(_ markdown: String) async throws -> MarkdownContent
}

public struct GFMParser: MarkdownParsing {
	public init() {}

	public func parse(_ markdown: String) async throws -> MarkdownContent {
		// 1. Convert Swift String to C-compatible string (UTF-8)
		guard let cString = markdown.cString(using: .utf8) else {
			throw MarkdownError.parsingFailed
		}
		
		// 2. Parse the document using cmark_parse_document with all required arguments
		// We use CMARK_OPT_DEFAULT (0) for options and the length of the cString.
		guard let root = cmark_parse_document(cString, cString.count - 1, CMARK_OPT_DEFAULT) else {
			throw MarkdownError.parsingFailed
		}
		
		// 3. Ensure memory is freed when this function exits using the correct node free function
		defer {
			cmark_node_free(root)
		}
		
		// 4. Use our bridge to transform the C tree into our Swift AST
		let bridge = GFMBridge()
		return bridge.transform(root: root)
	}
}

public enum MarkdownError: Error {
	case parsingFailed
}
