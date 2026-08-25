//
//  MarkdownBuilders.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//


import Foundation

/// A result builder that enables the declarative construction of a sequence of block-level Markdown nodes.
///
/// Use this builder to define the structure of a Markdown document or any component that accepts
/// a collection of `BlockNode` elements. It allows for nesting blocks, such as placing paragraphs
/// within a blockquote or list items within a list.
///
/// ### Example
///
/// ```swift
/// let content = MarkdownContentBuilder {
///     BlockNode.heading(.h1) {
///         "Hello World"
///     }
///     BlockNode.paragraph {
///         "This is a paragraph built with the DSL."
///     }
/// }
/// ```
@resultBuilder
public struct MarkdownContentBuilder {
    /// Combines multiple arrays of `BlockNode` into a single flattened array.
    ///
    /// - Parameter components: A variadic list of arrays containing `BlockNode` elements.
    /// - Returns: A single array containing all the provided block nodes.
    public static func buildBlock(_ components: [BlockNode]...) -> [BlockNode] {
        components.flatMap { $0 }
    }

    /// Wraps a single `BlockNode` into an array to support result builder syntax.
    ///
    /// - Parameter expression: The `BlockNode` to be included in the builder's output.
    /// - Returns: An array containing the provided `BlockNode`.
    public static func buildExpression(_ expression: BlockNode) -> [BlockNode] {
        [expression]
    }
}

/// A result builder that enables the declarative construction of a sequence of inline Markdown nodes.
///
/// This builder is designed to facilitate the creation of text-based content, providing seamless
/// integration for both `InlineNode` objects and raw `String` values. When a string is provided,
/// it is automatically converted into an `.text` node.
///
/// ### Example
///
/// ```swift
/// let inlineContent = InlineContentBuilder {
///     "This is plain text "
///     InlineNode.strong {
///         "and this is bold."
///     }
/// }
/// ```
@resultBuilder
public struct InlineContentBuilder {
    /// Combines multiple arrays of `InlineNode` into a single flattened array.
    ///
    /// - Parameter components: A variadic list of arrays containing `InlineNode` elements.
    /// - Returns: A single array containing all the provided inline nodes.
    public static func buildBlock(_ components: [InlineNode]...) -> [InlineNode] {
        components.flatMap { $0 }
    }

    /// Wraps a single `InlineNode` into an array to support result builder syntax.
    ///
    /// - Parameter expression: The `InlineNode` to be included in the builder's output.
    /// - Returns: An array containing the provided `InlineNode`.
    public static func buildExpression(_ expression: InlineNode) -> [InlineNode] {
        [expression]
    }
    
    /// Converts a raw `String` into an `.text` inline node.
    ///
    /// This allows for a more natural syntax when mixing plain text with styled Markdown nodes.
    ///
    /// - Parameter expression: The string to be converted.
    /// - Returns: An array containing an `.text` node with the provided string content.
    public static func buildExpression(_ expression: String) -> [InlineNode] {
        [.text(expression)]
    }
}
