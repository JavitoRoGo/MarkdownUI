//
//  BlockBoundaryKey.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// A PreferenceKey used to communicate the height or boundary of a block to its parent.
struct BlockBoundaryKey: PreferenceKey {
	// We change Value from CGRect to [CGRect] so we can track every block.
	typealias Value = [CGRect]

	static let defaultValue: [CGRect] = []

	static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
		value.append(contentsOf: nextValue())
	}
}
