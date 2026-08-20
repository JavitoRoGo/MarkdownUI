//
//  InlineRenderer.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// An internal engine responsible for transforming AST InlineNodes into a single AttributedString.
struct InlineRenderer {
    let theme: Theme
    let baseURL: URL?

    init(theme: Theme, baseURL: URL? = nil) {
        self.theme = theme
        self.baseURL = baseURL
    }

    /// Transforms a collection of inline nodes into a single AttributedString.
    func render(_ nodes: [InlineNode]) -> AttributedString {
        var combinedString = AttributedString()
        
        for node in nodes {
            let renderedNode = render(node)
            combinedString.append(renderedNode)
        }
        
        return combinedString
    }

    private func render(_ node: InlineNode) -> AttributedString {
        switch node {
        case .text(let string):
            return AttributedString(string)

        case .softBreak, .lineBreak:
            // Handle breaks by inserting appropriate characters or line attributes
            return AttributedString("\n")

        case .strong(let children):
            var attributed = render(children)
            applyStyle(theme.strongStyle, to: &attributed)
            return attributed

        case .emphasis(let children):
            var attributed = render(children)
            applyStyle(theme.emphasisStyle, to: &attributed)
            return attributed

        case .strikethrough(let children):
            // Implementation for strikethrough attribute
            let attributed = render(children)
            // We would add a custom attribute or use standard ones if available in the OS version
            return attributed

        case .code(let text):
            var attributed = AttributedString(text)
            applyStyle(theme.codeStyle, to: &attributed)
            return attributed

        case .link(let url, let title, let children):
            var attributed = render(children)
            attributed.link = url
            if let title = title {
                // Handle title logic if necessary
            }
            return attributed

        case .image(let url, let altText, _):
            // Images are often better handled as separate Views in a Block context, 
            // but for inline-images we provide the Alt text or a placeholder.
            return AttributedString("[\(altText)](\(url.absoluteString))")

        case .html(let html):
            // HTML rendering is complex; typically we return it as raw text 
            // unless a specific HTML sanitizer/renderer is provided.
            return AttributedString(html)
        }
    }

    /// Merges the theme's TextStyle into the AttributedString's AttributeContainer.
    private func applyStyle(_ style: MarkdownTextStyle, to attributedString: inout AttributedString) {
        var container = AttributeContainer()
        style.apply(to: &container)
        attributedString.mergeAttributes(container)
    }
}
