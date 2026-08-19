//
//  BlockStyle.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

/// A style for a block element that accepts a configuration object to produce a view.
public struct BlockStyle<Configuration>: Sendable where Configuration: Sendable {
	private let _makeView: @Sendable (Configuration) -> AnyView

	public init(@ViewBuilder _ makeView: @escaping @Sendable (Configuration) -> some View) {
		self._makeView = { config in AnyView(makeView(config)) }
	}

	@ViewBuilder
	public func makeView(with configuration: Configuration) -> some View {
		_makeView(configuration)
	}
}

/// A type-erased version of BlockStyle to allow storage in a heterogeneous Theme.
public struct AnyBlockStyle: Sendable {
	private let _makeView: @Sendable (Any) -> AnyView

	internal init<Configuration>(_ style: BlockStyle<Configuration>) where Configuration: Sendable {
		self._makeView = { config in
			guard let typedConfig = config as? Configuration else {
				fatalError("MarkdownUI: Invalid configuration type passed to BlockStyle")
			}
			// We explicitly wrap the 'some View' result into an 'AnyView'
			// to match the expected return type of the @Sendable closure.
			return AnyView(style.makeView(with: typedConfig))
		}
	}

	@ViewBuilder
	internal func makeView(with configuration: Any) -> some View {
		_makeView(configuration)
	}
}
