//
//  AST.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import Foundation

/// A container representing the complete parsed structure of a Markdown document.
///
/// `MarkdownContent` holds the top-level hierarchy of block nodes that make up
/// the entire document.
public struct MarkdownContent {
    /// The sequence of top-level block nodes in the document.
    public let blocks: [BlockNode]

    /// Initializes a new `MarkdownContent` with the provided blocks.
    /// - Parameter blocks: An array of `BlockNode` elements.
    public init(blocks: [BlockNode]) {
        self.blocks = blocks
    }
}

/// A representation of a block-level element in the Markdown document.
///
/// Block nodes are structural elements that define the layout of the document, 
/// such as headings, paragraphs, lists, or tables. Because Markdown allows 
/// nesting (e.g., a list item containing a paragraph), this enum is `indirect`.
public indirect enum BlockNode {
    /// A block-level quote, which can contain other nested blocks.
    case blockquote([BlockNode])
    /// An unordered list containing a sequence of list items.
    case bulletedList([ListItem])
    /// An ordered list containing a sequence of list items.
    case numberedList([ListItem])
    /// A list of task items with checkboxes.
    case taskList([ListItem])
    /// A multi-line code block, optionally specifying a programming language.
    case codeBlock(String, language: String?)
    /// A block containing raw HTML content.
    case htmlBlock(String)
    /// A standard paragraph containing inline text nodes.
    case paragraph([InlineNode])
    /// A heading of a specific hierarchical level, containing inline text.
    case heading(level: HeadingLevel, [InlineNode])
    /// A structured data table.
    case table(Table)
    /// A thematic break (horizontal rule).
    case thematicBreak

    /// The hierarchical levels available for headings.
    public enum HeadingLevel: Int, Comparable {
        case h1 = 1, h2, h3, h4, h5, h6

        /// Compares two heading levels based on their hierarchy.
        public static func < (lhs: HeadingLevel, rhs: HeadingLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

/// A single item within a list structure.
///
/// Each `ListItem` can contain its own sequence of block nodes, allowing for 
/// complex nested structures within lists.
public struct ListItem {
    /// The status of the checkbox if this is a task list item. 
    /// Nil if it is a standard bulleted or numbered list item.
    public let taskStatus: TaskStatus?
    /// The block-level content contained within this list item.
    public let children: [BlockNode]

    /// The state of a checkbox in a task list.
    public enum TaskStatus {
        case checked
        case unchecked
    }

    /// Initializes a new `ListItem`.
    /// - Parameters:
    ///   - taskStatus: The completion status for task lists. Defaults to `nil`.
    ///   - children: The block nodes contained within the item.
    public init(taskStatus: TaskStatus? = nil, children: [BlockNode]) {
        self.taskStatus = taskStatus
        self.children = children
    }
}

/// A representation of a Markdown table.
public struct Table {
    /// The header row of the table.
    public let header: [TableCell]
    /// The subsequent data rows of the table.
    public let rows: [[TableCell]]

    /// A single cell within a table.
    public struct TableCell {
        /// The inline content contained within the cell.
        public let content: [InlineNode]
    }

    /// Initializes a new `Table`.
    /// - Parameters:
    ///   - header: An array of cells representing the first row.
    ///   - rows: A nested array of cells representing the remaining rows.
    public init(header: [TableCell], rows: [[TableCell]]) {
        self.header = header
        self.rows = rows
    }
}

/// A representation of an inline-level element in the Markdown document.
///
/// Inline nodes are elements that exist within a block (like a paragraph) and 
/// handle text formatting, links, or images. Like `BlockNode`, this is an 
/// `indirect` enum to allow for nested styling (e.g., bold text inside emphasis).
public indirect enum InlineNode: Hashable {
    /// Plain text content.
    case text(String)
    /// A soft line break.
    case softBreak
    /// A hard line break.
    case lineBreak
    /// An inline code snippet.
    case code(String)
    /// Inline HTML content.
    case html(String)
    /// Text with emphasis (usually italics).
    case emphasis([InlineNode])
    /// Text with strong emphasis (usually bold).
    case strong([InlineNode])
    /// Text with a strikethrough effect.
    case strikethrough([InlineNode])
    /// A hyperlink to a specific URL.
    case link(url: URL, title: String?, [InlineNode])
    /// An embedded image.
    case image(url: URL, altText: String, destination: URL?)
}

extension Table.TableCell: Hashable {
	public static func == (lhs: Table.TableCell, rhs: Table.TableCell) -> Bool {
		lhs.content == rhs.content
	}
	public func hash(into hasher: inout Hasher) {
		hasher.combine(content)
	}
}
