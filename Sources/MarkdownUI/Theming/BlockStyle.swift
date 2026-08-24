//
//  BlockStyle.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

public struct BlockStyle<Configuration>: @unchecked Sendable where Configuration: Sendable {
    private let _makeView: (Configuration, AnyView) -> AnyView

    public init(@ViewBuilder _ makeView: @escaping (Configuration, AnyView) -> some View) {
        self._makeView = { configuration, content in AnyView(makeView(configuration, content)) }
    }

    public init(@ViewBuilder _ makeView: @escaping (Configuration) -> some View) {
        self._makeView = { configuration, _ in AnyView(makeView(configuration)) }
    }

    @ViewBuilder
    public func makeView(with configuration: Configuration, content: AnyView) -> some View {
        _makeView(configuration, content)
    }
}

public struct AnyBlockStyle: @unchecked Sendable {
    private let _makeView: (Any, AnyView) -> AnyView

    internal init<Configuration>(_ style: BlockStyle<Configuration>) where Configuration: Sendable {
        self._makeView = { configuration, content in
            guard let typedConfiguration = configuration as? Configuration else {
                fatalError("MarkdownUI: Invalid configuration type passed to BlockStyle")
            }
            return AnyView(style.makeView(with: typedConfiguration, content: content))
        }
    }

    @ViewBuilder
    internal func makeView(with configuration: Any, content: AnyView) -> some View {
        _makeView(configuration, content)
    }
}
