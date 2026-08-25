import Foundation
import cmark_gfm

/// A protocol that defines the requirements for a component capable of parsing Markdown text.
///
/// Implementing types must be able to take a raw Markdown string and transform it into 
/// a structured `MarkdownContent` object representing the Abstract Syntax Tree (AST).
///
/// Implementations should be `Sendable` to ensure they can be safely used within 
/// Swift Concurrency contexts.
public protocol MarkdownParsing: Sendable {
	/// Parses a Markdown string into its structured representation.
	///
	/// - Parameter markdown: The raw Markdown text to be parsed.
	/// - Returns: A `MarkdownContent` object containing the parsed hierarchy of nodes.
	/// - Throws: An error if the parsing process fails.
	func parse(_ markdown: String) async throws -> MarkdownContent
}

/// A parser implementation that follows the GitHub Flavored Markdown (GFM) specification.
///
/// `GFMParser` uses the high-performance `cmark_gfm` C library to perform the heavy lifting 
/// of parsing. It is the default engine for converting Markdown text into the native 
/// node structures used by this package.
public struct GFMParser: MarkdownParsing {
	/// Creates a new instance of a `GFMParser`.
	public init() {}

	/// Parses a Markdown string using GitHub Flavored Markdown rules.
	///
	/// This method converts the input string into a C-compatible format, invokes 
	/// the `cmark_gfm` parser, and then transforms the resulting tree into 
	/// a native `MarkdownContent` object via an internal bridge.
	///
	/// - Parameter markdown: The raw Markdown text to be parsed.
	/// - Returns: A `MarkdownContent` object containing the parsed hierarchy of nodes.
	/// - Throws: `MarkdownError.parsingFailed` if the string cannot be converted 
	///   to UTF-8 or if the underlying C parser fails to initialize.
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

/// Errors that can occur during the Markdown parsing process.
public enum MarkdownError: Error {
	/// Indicates that the parser encountered a failure while processing the input string 
	/// or while interacting with the underlying C engine.
	case parsingFailed
}
