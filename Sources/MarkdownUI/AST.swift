//
//  AST.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import Foundation

public struct MarkdownContent {
    public let blocks: [BlockNode]

    public init(blocks: [BlockNode]) {
        self.blocks = blocks
    }
}

public indirect enum BlockNode {
    case blockquote([BlockNode])
    case bulletedList([ListItem])
    case numberedList([ListItem])
    case taskList([ListItem])
    case codeBlock(String, language: String?)
    case htmlBlock(String)
    case paragraph([InlineNode])
    case heading(level: HeadingLevel, [InlineNode])
    case table(Table)
    case thematicBreak

    public enum HeadingLevel: Int, Comparable {
        case h1 = 1, h2, h3, h4, h5, h6

        public static func < (lhs: HeadingLevel, rhs: HeadingLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

public struct ListItem {
    public let taskStatus: TaskStatus?
    public let children: [BlockNode]

    public enum TaskStatus {
        case checked
        case unchecked
    }

    public init(taskStatus: TaskStatus? = nil, children: [BlockNode]) {
        self.taskStatus = taskStatus
        self.children = children
    }
}

public struct Table {
    public let header: [TableCell]
    public let rows: [[TableCell]]

    public struct TableCell {
        public let content: [InlineNode]
    }

    public init(header: [TableCell], rows: [[TableCell]]) {
        self.header = header
        self.rows = rows
    }
}

public indirect enum InlineNode: Hashable {
    case text(String)
    case softBreak
    case lineBreak
    case code(String)
    case html(String)
    case emphasis([InlineNode])
    case strong([InlineNode])
    case strikethrough([InlineNode])
    case link(url: URL, title: String?, [InlineNode])
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
