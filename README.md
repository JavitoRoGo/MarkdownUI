# MarkdownUI 📝

A powerful, declarative SwiftUI framework for rendering Markdown content with first-class support for real-time streaming. Built specifically to handle the dynamic nature of LLM (Large Language Model) responses.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20|macOS%20|iPadOS-blue.svg)](#)

## ✨ Features

*   **🚀 Streaming Support**: Native support for `Binding<String>`, making it perfect for AI chat interfaces where text arrives token-by-token.
*   **🎨 Deep Theming**: Fully customizable styles for every element (headings, lists, code blocks, links, etc.) using a type-safe SwiftUI DSL.
*   **🏗️ Programmatic AST**: Don't just parse strings—build Markdown structures manually using a clean Swift DSL.
*   **🔗 Environment Aware**: Easily override styles for specific sub-hierarchies using SwiftUI Environment keys.
*   **📦 GFM Ready**: Designed to follow GitHub Flavored Markdown patterns.

## 🚀 Quick Start

### 1. Basic Usage (Static String)
Render a simple markdown string instantly.

```swift
import MarkdownUI

struct ContentView: View {
    let markdown = "# Hello\nThis is **bold** text."

    var body: some View {
        MarkdownView(markdown)
    }
}
```

2. AI Streaming (The "Killer" Feature)
Perfect for ChatGPT-like interfaces. Pass a Binding to your growing string, and the view will update efficiently as new tokens arrive.

```swift
import SwiftUI
import MarkdownUI

struct ChatView: View {
    @State private var streamingText = ""

    var body: some View {
        VStack {
            MarkdownView(streaming: $streamingText)
            
            Button("Simulate AI Response") {
                simulateLLM()
            }
        }
    }

    func simulateLLM() {
        // As you append text to streamingText, 
        // MarkdownUI updates the view seamlessly.
    }
}
```

3. Programmatic Construction (DSL)
Build complex markdown structures without writing a single string.

```swift
let content = MarkdownContent(blocks: [
    .heading(.h1, [
        .text("Custom Title")
    ]),
    .paragraph([
        .text("This was built "),
        .strong([.text("programmatically")])
    ])
])

MarkdownView(content: content)
```

## 🎨 Customizing the Look

You can theme your entire application or just specific sections using the .markdownTheme() modifier.

```swift
extension Theme {
    static let myCustomTheme = Theme(
        textStyle: MarkdownTextStyle {
            ColorStyle(.gray)
        },
        strongStyle: MarkdownTextStyle {
            ColorStyle(.blue)
            // Add more styles here...
        },
        // ... other style configurations
    )
}

// Apply globally
MarkdownView("# Title")
    .markdownTheme(.myCustomTheme)

// Or override locally
VStack {
    MarkdownView("# I am standard")
    
    MarkdownView("# I am blue!")
        .markdownTextStyle(.strong, MarkdownTextStyle {
            ColorStyle(.blue)
        })
}
```

## 🛠 Architecture Overview

MarkdownUI is built on three pillars:
1. AST (Abstract Syntax Tree): A robust internal representation of Markdown nodes (BlockNode and InlineNode).
2. Parser: Converts raw strings into the AST.
3. Renderer: Transforms the AST into highly optimized SwiftUI AttributedString components.

## 🤝 Contributing

Contributions are welcome! Whether it's fixing a bug, adding support for new Markdown extensions, or improving performance, please feel free to open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
