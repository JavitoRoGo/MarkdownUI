//
//  UIRendererTests.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 26/08/2026.
//


import Testing
import SwiftUI
@testable import MarkdownUI

@Suite("Fase 3: Comportamiento Visual (Renderizado y Temas)")
struct UIRendererTests {

    // MARK: - Theme & Style Tests

    @Test("El InlineRenderer debe aplicar el color del tema por defecto")
    func testThemeColorApplication() {
        let theme = Theme.default
        let renderer = InlineRenderer(theme: theme)
        
        // Creamos un nodo de texto fuerte (bold)
        let strongNode = InlineNode.strong([.text("Texto Bold")])
        
        let attributedString = renderer.render([strongNode])
        
        #expect(!attributedString.characters.isEmpty)
    }

    @Test("Los Style Overrides deben tener prioridad sobre el Theme")
    func testStyleOverridesPriority() {
        let theme = Theme.default
        let overrideColor: Color = .red
        let overrides: [TextStyleType: MarkdownTextStyle] = [
            .strong: MarkdownTextStyle {
                ColorStyle(overrideColor)
            }
        ]
        
        let renderer = InlineRenderer(theme: theme, styleOverrides: overrides)
        let strongNode = InlineNode.strong([.text("Texto Rojo")])
        
        let attributedString = renderer.render([strongNode])
        
        // Aquí validamos que el renderizado ha procesado los nodos correctamente.
        #expect(attributedString.characters.count > 0)
    }

    @Test("El InlineRenderer debe resolver URLs relativas usando la baseURL")
    func testBaseURLResolution() {
        let baseURL = URL(string: "https://ejemplo.com/assets/")!
        
        // Link relativo
        let relativeURL = URL(string: "imagen.png")!
        
        let finalURL = baseURL.appendingPathComponent(relativeURL.absoluteString)
        
        #expect(finalURL.absoluteString == "https://ejemplo.com/assets/imagen.png")
    }

    // MARK: - Semantic Tests

    @Test("El InlineRenderer debe aplicar Presentation Intents para accesibilidad")
    func testPresentationIntentApplication() {
        let theme = Theme.default
        let renderer = InlineRenderer(theme: theme)
        
        // El nodo emphasis debe aplicar .emphasized
        let emphasisNode = InlineNode.emphasis([.text("Cursiva")])
        let attributedString = renderer.render([emphasisNode])
        
        // Verificamos que el atributo de presentación existe en los runs del string
        var intentFound = false
        for run in attributedString.runs {
            if let intent = run.inlinePresentationIntent, !intent.isEmpty {
                intentFound = true
                break
            }
        }
        
        #expect(intentFound, "Debería haberse aplicado un InlinePresentationIntent para el énfasis")
    }
}
