import SwiftUI

/// The main container that iterates through BlockNodes and manages layout spacing.
struct BlockSequence: View {
    let blocks: [BlockNode]
    @Environment(\.markdownTheme) var theme
    @Environment(\.tightSpacingEnabled) var tightSpacingEnabled

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

/// Helper to apply the type-erased block style while preserving the original content.
extension View {
    @ViewBuilder
    func applyBlockStyle(_ style: AnyBlockStyle) -> some View {
        style.makeView(with: (), content: AnyView(self))
    }
}

/// Overload specifically for list styles that require ListMarkerConfiguration.
extension View {
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
