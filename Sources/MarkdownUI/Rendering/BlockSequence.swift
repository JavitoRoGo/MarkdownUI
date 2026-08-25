import SwiftUI

/// A view that renders a sequence of Markdown block nodes in a vertical layout.
///
/// `BlockSequence` is responsible for iterating through an array of `BlockNode` objects 
/// and transforming each one into its corresponding SwiftUI representation (such as 
/// headings, paragraphs, lists, or code blocks).
///
/// The spacing between blocks is determined by the `tightSpacingEnabled` environment value:
/// - When `true`, a compact spacing of 4 points is used.
/// - When `false`, a more relaxed spacing of 16 points is used.
///
/// The visual appearance of each block (colors, fonts, margins, etc.) is automatically 
/// applied using the styles defined in the current `markdownTheme`.
struct BlockSequence: View {
    /// The collection of Markdown blocks to be rendered.
    let blocks: [BlockNode]
    
    @Environment(\.markdownTheme) var theme
    @Environment(\.tightSpacingEnabled) var tightSpacingEnabled

    /// Initializes a new `BlockSequence` with the provided blocks.
    /// - Parameter blocks: An array of `BlockNode` elements to render.
    public init(blocks: [BlockNode]) {
        self.blocks = blocks
    }

    var body: some View {
        VStack(alignment: .leading, spacing: tightSpacingEnabled ? 4 : 16) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                renderBlock(block)
            }
        }
    }

    /// Determines which view to use for a given `BlockNode` and applies its themed style.
    ///
    /// - Parameter block: The block node to render.
    /// - Returns: A configured SwiftUI view representing the block.
    @ViewBuilder
    private func renderBlock(_ block: BlockNode) -> some View {
        switch block {
        case .heading(let level, let inlines):
            HeadingView(level: level, inlines: inlines)
                .applyBlockStyle(theme.headingStyle[level.rawValue] ?? AnyBlockStyle(BlockStyle<Void> { _, content in content }))

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

extension View {
    /// Wraps the current view in a block-level style from the Markdown theme.
    ///
    /// This modifier allows for applying complex styling (like padding, backgrounds, or borders) 
    /// to a rendered Markdown block using an `AnyBlockStyle`.
    ///
    /// - Parameter style: The block style to apply.
    /// - Returns: A view wrapped in the specified style.
    @ViewBuilder
    func applyBlockStyle(_ style: AnyBlockStyle) -> some View {
        style.makeView(with: (), content: AnyView(self))
    }
}

extension View {
    /// Wraps the current view in a list-specific style from the Markdown theme.
    ///
    /// This modifier is used specifically for list types to apply appropriate markers 
    /// (like bullets or numbers) provided by the `AnyBlockStyle`.
    ///
    /// - Parameter style: The list style to apply.
    /// - Returns: A view wrapped in the specified list style.
    @ViewBuilder
    func applyListStyle(_ style: AnyBlockStyle) -> some View {
        style.makeView(
            with: ListMarkerConfiguration(
                bullet: { AnyView(Circle().fill(.primary)) },
                number: { AnyView(Text("1.")) }
            ),
            content: AnyView(self)
        )
    }
}
