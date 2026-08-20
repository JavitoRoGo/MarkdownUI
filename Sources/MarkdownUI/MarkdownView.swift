//
//  MarkdownView.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 20/08/2026.
//


import SwiftUI

/// The primary entry point for rendering Markdown in SwiftUI.
public struct MarkdownView: View {
    private let content: MarkdownContent
    @Environment(\.markdownTheme) private var theme
    @Environment(\.baseURL) private var baseURL

    // Initializer for raw String (Parses on initialization)
    public init(_ markdown: String, parser: MarkdownParsing = GFMParser()) async throws {
        let parsedContent = try await parser.parse(markdown)
        self.content = parsedContent
    }

    // Initializer for pre-parsed MarkdownContent
    public init(content: MarkdownContent) {
        self.content = content
    }

    // Initializer for the DSL (@MarkdownContentBuilder)
    public init(@MarkdownContentBuilder _ content: () -> [BlockNode]) {
        self.content = MarkdownContent(blocks: content())
    }

    public var body: some View {
        BlockSequence(blocks: content.blocks)
            .environment(\.baseURL, baseURL)
    }
}

// MARK: - Styling Modifiers

extension View {
    /// Applies a custom theme to all Markdown elements within this view hierarchy.
    public func markdownTheme(_ theme: Theme) -> some View {
        self.environment(\.markdownTheme, theme)
    }

    /// Specifically applies a text style to inline elements within this view hierarchy.
    /// Note: This is typically part of a larger Theme object, but provided for fine-grained control.
    public func markdownTextStyle(_ style: MarkdownTextStyle) -> some View {
        // In our architecture, text styles are part of the Theme. 
        // To implement this modifier, we'd create a specialized EnvironmentKey
        // or update the Theme in the environment.
        self // Placeholder for implementation
    }

    /// Applies a custom block style to specific elements within this view hierarchy.
    public func markdownBlockStyle<Configuration: Sendable>(
        _ style: BlockStyle<Configuration>,
        body: @escaping (Configuration) -> AnyView
    ) -> some View {
        // Implementation would involve injecting configuration via Environment
        self 
    }
}
