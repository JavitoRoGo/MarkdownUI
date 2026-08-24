//
//  MarkdownBuilders.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//


import Foundation

@resultBuilder
public struct MarkdownContentBuilder {
    public static func buildBlock(_ components: [BlockNode]...) -> [BlockNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: BlockNode) -> [BlockNode] {
        [expression]
    }
}

@resultBuilder
public struct InlineContentBuilder {
    public static func buildBlock(_ components: [InlineNode]...) -> [InlineNode] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: InlineNode) -> [InlineNode] {
        [expression]
    }
    
    public static func buildExpression(_ expression: String) -> [InlineNode] {
        [.text(expression)]
    }
}
