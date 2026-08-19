//
//  Parser.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import Foundation

/// The interface for the Markdown parsing engine.
public protocol MarkdownParsing {
    func parse(_ markdown: String) async throws -> MarkdownContent
}

/// A bridge that traverses the cmark-gfm node tree and transforms it into Swift nodes.
public struct GFMParser: MarkdownParsing {
    
    public init() {}

    public func parse(_ markdown: String) async throws -> MarkdownContent {
        // In a real implementation, this is where we call into the C library:
        // 1. cmark_parse_document(...)
        // 2. Walk the tree recursively using a visitor pattern.
        // 3. Map each cmark_node type to our BlockNode or InlineNode enums.
        
        // Placeholder for implementation logic
        return MarkdownContent(blocks: [])
    }
    
    // Private helper methods that will be implemented once the C bridge is ready:
    // private func parseBlock(node: UnsafeMutablePointer<cmark_node>) -> BlockNode
    // private func parseInline(node: UnsafeMutablePointer<cmark_node>) -> InlineNode
}
