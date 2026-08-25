//
//  BlockStyle.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 19/08/2026.
//

import SwiftUI

/// A definition of how a Markdown block should be visually wrapped or styled.
///
/// `BlockStyle` provides a way to encapsulate transformation logic that wraps a content view 
/// with additional visual elements (like backgrounds, borders, or padding) based on a 
/// specific `Configuration`.
///
/// This type is generic over its `Configuration`, allowing different blocks to receive 
/// different types of metadata during the styling process.
///
/// ### Example
///
/// ```swift
/// // A style that adds padding using no extra configuration
/// let simpleStyle = BlockStyle<Void> { _, content in
///     content.padding()
/// }
///
/// // A style that uses a specific configuration (e.g., a color)
/// let coloredStyle = BlockStyle<Color> { color, content in
///     content.padding().background(color)
/// }
/// ```
public struct BlockStyle<Configuration>: @unchecked Sendable where Configuration: Sendable {
    private let _makeView: (Configuration, AnyView) -> AnyView

    /// Initializes a new `BlockStyle` with a transformation that depends on a configuration.
    ///
    /// - Parameter makeView: A closure that takes the provided `Configuration` and the 
    ///   original content view, returning a styled version of that content.
    public init(@ViewBuilder _ makeView: @escaping (Configuration, AnyView) -> some View) {
        self._makeView = { configuration, content in AnyView(makeView(configuration, content)) }
    }

    /// Initializes a new `BlockStyle` with a transformation that ignores the configuration.
    ///
    /// - Parameter makeView: A closure that takes only the original content view, 
    ///   returning a styled version of that content.
    public init(@ViewBuilder _ makeView: @escaping (Configuration) -> some View) {
        self._makeView = { configuration, _ in AnyView(makeView(configuration)) }
    }

    /// Applies the style transformation to the provided content.
    ///
    /// - Parameters:
    ///   - configuration: The metadata or settings used to determine how to apply the style.
    ///   - content: The original view that is to be styled.
    /// - Returns: A new view wrapped with the defined styling logic.
    @ViewBuilder
    public func makeView(with configuration: Configuration, content: AnyView) -> some View {
        _makeView(configuration, content)
    }
}

/// A type-erased wrapper for `BlockStyle`.
///
/// `AnyBlockStyle` allows different `BlockStyle<Configuration>` instances with 
/// varying generic types to be stored in a single collection (such as a theme).
/// It preserves the ability to apply the underlying styling by internally 
/// managing the type casting during the rendering process.
public struct AnyBlockStyle: @unchecked Sendable {
    private let _makeView: (Any, AnyView) -> AnyView

    /// Creates an `AnyBlockStyle` from a specific `BlockStyle`.
    ///
    /// - Parameter style: The typed `BlockStyle` to erase.
    internal init<Configuration>(_ style: BlockStyle<Configuration>) where Configuration: Sendable {
        self._makeView = { configuration, content in
            guard let typedConfiguration = configuration as? Configuration else {
                fatalError("MarkdownUI: Invalid configuration type passed to BlockStyle")
            }
            return AnyView(style.makeView(with: typedConfiguration, content: content))
        }
    }

    /// Applies the underlying erased style to the provided content.
    ///
    /// - Parameters:
    ///   - configuration: The configuration object (expected to match the original `BlockStyle` type).
    ///   - content: The original view to be styled.
    /// - Returns: A new view wrapped with the underlying styling logic.
    @ViewBuilder
    internal func makeView(with configuration: Any, content: AnyView) -> some View {
        _makeView(configuration, content)
    }
}
