import Foundation
import cmark_gfm

public protocol MarkdownParsing: Sendable {
	func parse(_ markdown: String) async throws -> MarkdownContent
}

public struct GFMParser: MarkdownParsing {
	public init() {}

	public func parse(_ markdown: String) async throws -> MarkdownContent {
		guard let cString = markdown.cString(using: .utf8) else {
			throw MarkdownError.parsingFailed
		}
		
		guard let root = cmark_parse_document(cString, cString.count - 1, CMARK_OPT_DEFAULT) else {
			throw MarkdownError.parsingFailed
		}
		
		defer {
			cmark_node_free(root)
		}
		
		let bridge = GFMBridge()
		return bridge.transform(root: root)
	}
}

public enum MarkdownError: Error {
	case parsingFailed
}
