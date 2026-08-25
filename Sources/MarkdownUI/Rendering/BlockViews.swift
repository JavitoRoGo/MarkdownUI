//
//  BlockViews.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// A view that renders a Markdown heading.
///
/// The font size and weight of the heading are automatically adjusted based on its `level`.
struct HeadingView: View {
    /// The hierarchical level of the heading (e.g., h1, h2).
    let level: BlockNode.HeadingLevel
    /// The inline content to be rendered within the heading.
    let inlines: [InlineNode]
    
    @Environment(\.markdownTheme) var theme

    var body: some View {
        let renderer = InlineRenderer(theme: theme)
        Text(renderer.render(inlines))
            .font(fontForLevel(level))
    }

    /// Maps a `HeadingLevel` to an appropriate SwiftUI `Font`.
    private func fontForLevel(_ level: BlockNode.HeadingLevel) -> Font {
        switch level {
        case .h1: return .title.bold()
        case .h2: return .title2.bold()
        case .h3: return .title3.bold()
        default: return .headline.bold()
        }
    }
}

/// A view that renders a standard Markdown paragraph.
struct ParagraphView: View {
    /// The inline content representing the paragraph text.
    let inlines: [InlineNode]
    
    @Environment(\.markdownTheme) var theme

    var body: some View {
        let renderer = InlineRenderer(theme: theme)
        Text(renderer.render(inlines))
    }
}

/// A view that renders a code block with a monospaced font and a distinct background.
struct CodeBlockView: View {
    /// The raw text content of the code.
    let code: String
    /// An optional identifier for the programming language used in the block.
    let language: String?

    var body: some View {
        Text(code)
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
    }
}

/// A view that renders Markdown lists (bulleted, numbered, or task lists).
struct ListView: View {
    /// The items contained within the list.
    let items: [ListItem]
    /// The specific type of list being rendered.
    let type: ListType

    /// Defines the visual style of the list markers.
    enum ListType {
        case bulleted, numbered, task
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top) {
                    markerView(for: item, index: index)
                    contentView(for: item)
                }
            }
        }
    }

    /// Provides the appropriate marker (bullet, number, or checkbox) for a list item.
    @ViewBuilder
    private func markerView(for item: ListItem, index: Int) -> some View {
        switch type {
        case .bulleted: Circle().frame(width: 6, height: 6).padding(.top, 8)
        case .numbered: Text("\(index + 1).")
        case .task:
            if item.taskStatus == .checked { Image(systemName: "checkmark.square") }
            else { Image(systemName: "square") }
        }
    }

    /// Renders the content of a list item, which can itself contain multiple block nodes.
    @ViewBuilder
    private func contentView(for item: ListItem) -> some View {
        BlockSequence(blocks: item.children)
    }
}

/// A view that renders a Markdown blockquote with indentation and visual borders.
struct BlockquoteView: View {
    /// The sequence of blocks contained within the blockquote.
    let children: [BlockNode]
    
    @Environment(\.markdownTheme) var theme

	var body: some View {
		BlockSequence(blocks: children)
			.padding(.leading, 16)
			.border(Color.gray.opacity(0.2), width: 1)
	}
}

/// A view that renders a Markdown table with headers and data rows.
struct TableView: View {
    /// The structured data representing the table.
    let table: Table

    @Environment(\.markdownTheme) var theme

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				ForEach(table.header, id: \.content) { cell in
					renderCell(cell)
						.frame(maxWidth: .infinity)
				}
			}
			.font(.headline)
			.background(Color.gray.opacity(0.1))

			ForEach(table.rows, id: \.self) { row in
				Divider()
				HStack {
					ForEach(row, id: \.content) { cell in
						renderCell(cell)
							.frame(maxWidth: .infinity)
					}
				}
			}
		}
	}

	/// Renders the inline content of an individual table cell.
	@ViewBuilder
    private func renderCell(_ cell: Table.TableCell) -> some View {
		let renderer = InlineRenderer(theme: theme)
		Text(renderer.render(cell.content))
	}
}
