//
//  BlockBoundaryKey.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

/// A preference key used to collect the layout boundaries of block-level elements during rendering.
///
/// `BlockBoundaryKey` allows child views representing Markdown blocks to pass their `CGRect` 
/// frames up the view hierarchy. This is essential for the renderer to track the precise 
/// positioning and sizing of different sections within the document.
struct BlockBoundaryKey: PreferenceKey {
	/// The type of value being collected, which is an array of rectangles.
	typealias Value = [CGRect]

	/// The default value when no preferences have been set by any child views.
	static let defaultValue: [CGRect] = []

	/// Combines the values from multiple children into a single collection.
	///
	/// - Parameters:
	///   - value: The current accumulated array of rectangles.
	///   - nextValue: A closure that returns the next set of rectangles from a sibling or child view.
	static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
		value.append(contentsOf: nextValue())
	}
}
