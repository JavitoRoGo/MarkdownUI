//
//  BlockViews.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// Renders a heading using AttributedString for content.
struct HeadingView: View {
    let level: BlockNode.HeadingLevel
    let inlines: [InlineNode]
    @Environment(\.markdownTheme) var theme

    var body: some View {
        let renderer = InlineRenderer(theme: theme)
        Text(renderer.render(inlines))
            .font(fontForLevel(level))
    }

    private func fontForLevel(_ level: BlockNode.HeadingLevel) -> Font {
        switch level {
        case .h1: return .title.bold()
        case .h2: return .title2.bold()
        case .h3: return .title3.bold()
        default: return .headline.bold()
        }
    }
}

/// Renders a standard paragraph.
struct ParagraphView: View {
    let inlines: [InlineNode]
    @Environment(\.markdownTheme) var theme

    var body: some View {
        let renderer = InlineRenderer(theme: theme)
        Text(renderer.render(inlines))
    }
}

/// Renders a code block with syntax highlighting capability.
struct CodeBlockView: View {
    let code: String
    let language: String?

    var body: some View {
        Text(code)
            .font(.system(.body, design: .monospaced))
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 8))
    }
}

/// Renders a list (bulleted, numbered, or task).
struct ListView: View {
    let items: [ListItem]
    let type: ListType

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

    @ViewBuilder
    private func contentView(for item: ListItem) -> some View {
        BlockSequence(blocks: item.children)
    }
}

/// Renders a blockquote element.
struct BlockquoteView: View {
	let children: [BlockNode]
	@Environment(\.markdownTheme) var theme

	var body: some View {
		// We use BlockSequence recursively to render the content inside the blockquote
		BlockSequence(blocks: children)
			.padding(.leading, 16)
			.border(Color.gray.opacity(0.2), width: 1) // Visual representation of the quote bar
	}
	
	@ViewBuilder
	private func renderCell(_ cell: Table.TableCell) -> some View {
		let renderer = InlineRenderer(theme: theme)
		Text(renderer.render(cell.content))
	}
}

/// Renders a GFM table.
struct TableView: View {
	let table: Table
	@Environment(\.markdownTheme) var theme

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Header Row
			HStack {
				ForEach(table.header, id: \.content) { cell in
					renderCell(cell)
						.frame(maxWidth: .infinity)
				}
			}
			.font(.headline)
			.background(Color.gray.opacity(0.1))

			// Data Rows
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

	@ViewBuilder
    private func renderCell(_ cell: Table.TableCell) -> some View {
        let renderer = InlineRenderer(theme: theme)
        Text(renderer.render(cell.content))
    }
}
