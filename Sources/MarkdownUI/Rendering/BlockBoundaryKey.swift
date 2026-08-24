//
//  BlockBoundaryKey.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//


import SwiftUI

struct BlockBoundaryKey: PreferenceKey {
	typealias Value = [CGRect]

	static let defaultValue: [CGRect] = []

	static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
		value.append(contentsOf: nextValue())
	}
}
