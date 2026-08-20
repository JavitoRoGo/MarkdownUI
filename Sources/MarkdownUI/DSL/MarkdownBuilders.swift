//
//  MarkdownBuilders.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//


import Foundation

/// A result builder used to compose a collection of BlockNodes.
@resultBuilder
public struct MarkdownContentBuilder {
    public static func buildBlock(_ components: [BlockNode]...) -> [BlockNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: BlockNode) -> [BlockNode] {
        [expression]
    }
}

/// A result builder used to compose a collection of InlineNodes within a block.
@resultBuilder
public struct InlineContentBuilder {
    public static func buildBlock(_ components: [InlineNode]...) -> [InlineNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: InlineNode) -> [InlineNode] {
        [expression]
    }
    
    /// Allows using raw Strings directly in the DSL, e.g., "Hello"
    public static func buildExpression(_ expression: String) -> [InlineNode] {
        [.text(expression)]
    }
}
