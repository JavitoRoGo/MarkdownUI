//
//  BlockSequence.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

/// The main container that iterates through BlockNodes and manages layout spacing.
struct BlockSequence: View {
	let blocks: [BlockNode]
	@Environment(\.markdownTheme) var theme
	@Environment(\.tightSpacingEnabled) var tightSpacingEnabled
	
	// We will store the calculated paddings here to avoid re-calculating
	// during every single frame of a layout pass.
	@State private var blockPaddings: [Int: CGFloat] = [:]

	public init(blocks: [BlockNode]) {
		self.blocks = blocks
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
				renderBlock(block)
					.padding(.top, blockPaddings[index] ?? 0) // Apply dynamic padding
					.background(
						GeometryReader { proxy in
							Color.clear.preference(
								key: BlockBoundaryKey.self,
								value: [proxy.frame(in: .named("MarkdownContent"))]
							)
						}
					)
			}
		}
		.coordinateSpace(name: "MarkdownContent")
		// This is where the magic happens: observing the boundaries reported by children.
		.onPreferenceChange(BlockBoundaryKey.self) { boundaries in
			calculatePaddings(for: boundaries)
		}
	}

	/// Calculates the necessary top padding for each block based on its predecessor's bottom edge.
	private func calculatePaddings(for allBoundaries: [CGRect]) {
		var newPaddings: [Int: CGFloat] = [:]
		
		// We iterate starting from the second block (index 1)
		for i in 1..<allBoundaries.count {
			let previousBlock = allBoundaries[i-1]
			let currentBlock = allBoundaries[i]
			
			// The gap is the distance between the bottom of the prev and top of current
			let gap = currentBlock.minY - previousBlock.maxY
			
			if gap > 0 {
				// If there's a natural gap (e.g. from internal element padding), use it.
				newPaddings[i] = gap
			} else {
				// If they overlap or touch, apply our custom spacing rules.
				let baseSpacing: CGFloat = tightSpacingEnabled ? 4 : 16
				newPaddings[i] = baseSpacing
			}
		}
		
		// Update state on the main actor to trigger layout update
		Task { @MainActor in
			self.blockPaddings = newPaddings
		}
	}

	@ViewBuilder
	private func renderBlock(_ block: BlockNode) -> some View {
		switch block {
		case .heading(let level, let inlines):
			HeadingView(level: level, inlines: inlines)
				.applyBlockStyle(theme.headingStyle[level.rawValue] ?? AnyBlockStyle(BlockStyle<Void> { _ in EmptyView() }))

		case .paragraph(let inlines):
			ParagraphView(inlines: inlines)
				.applyBlockStyle(theme.paragraphStyle)

		case .blockquote(let children):
			BlockquoteView(children: children)
				.applyBlockStyle(theme.blockquoteStyle)

		case .bulletedList(let items):
			ListView(items: items, type: .bulleted)
				.applyListStyle(theme.listStyle)

		case .numberedList(let items):
			ListView(items: items, type: .numbered)
				.applyListStyle(theme.listStyle)

		case .taskList(let items):
			ListView(items: items, type: .task)
				.applyListStyle(theme.listStyle)

		case .codeBlock(let code, let language):
			CodeBlockView(code: code, language: language)
				.applyBlockStyle(theme.codeBlockStyle)

		case .table(let table):
			TableView(table: table)
				.applyBlockStyle(theme.tableStyle)

		case .thematicBreak:
			Divider()
			
		case .htmlBlock(let html):
			Text(html)
		}
	}
}

/// Helper to apply the type-erased block style for blocks without specific config (Void).
extension View {
	@ViewBuilder
	func applyBlockStyle(_ style: AnyBlockStyle) -> some View {
		style.makeView(with: ())
	}
}

/// Overload specifically for list styles that require ListMarkerConfiguration.
extension View {
	@ViewBuilder
	func applyListStyle(_ style: AnyBlockStyle) -> some View {
		// In a production app, this configuration would come from the theme's settings
		style.makeView(with: ListMarkerConfiguration(
			bullet: { AnyView(Circle().fill(.primary)) },
			number: { AnyView(Text("1.")) }
		))
	}
}
