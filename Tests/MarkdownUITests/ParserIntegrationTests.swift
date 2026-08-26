//
//  ParserIntegrationTests.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 26/08/2026.
//


import Testing
import Foundation
@testable import MarkdownUI

@Suite("Fase 2: Integración (Parser & Data Flow)")
struct ParserIntegrationTests {

    // MARK: - GFMParser Real Tests

    @Test("GFMParser debe convertir Markdown básico en el AST correcto")
    func testGFMParserBasicConversion() async throws {
        let parser = GFMParser()
        let markdown = "# Hello\nThis is **bold**."
        
        let content = try await parser.parse(markdown)
        
        // Verificar Heading
        guard case .heading(let level, let inlines) = content.blocks[0] else {
            Issue.record("El primer bloque no es un heading")
            return
        }
        #expect(level == .h1)
        #expect(inlines.count == 1)
        #expect(inlines[0] == .text("Hello"))

        // Verificar Paragraph + Bold
        guard case .paragraph(let pInlines) = content.blocks[1] else {
            Issue.record("El segundo bloque no es un paragraph")
            return
        }
        #expect(pInlines.count == 3)
        #expect(pInlines[0] == .text("This is "))
        if case .strong(let strongInlines) = pInlines[1] {
            #expect(strongInlines[0] == .text("bold"))
        } else {
            Issue.record("El segundo inline no es .strong")
        }
    }

    @Test("GFMParser debe manejar correctamente una lista de tareas (TaskList)")
    func testGFMParserTaskList() async throws {
        let parser = GFMParser()
        let markdown = "- [x] Done\n- [ ] Not done"
        
        let content = try await parser.parse(markdown)
        
        guard case .taskList(let items) = content.blocks[0] else {
            Issue.record("No se detectó una TaskList")
            return
        }
        #expect(items.count == 2)
        #expect(items[0].taskStatus == .checked)
        #expect(items[1].taskStatus == .unchecked)
    }

    // MARK: - Mock Parser & Robustness Tests

    /// Un parser simulado para probar cómo reacciona la UI ante fallos.
    struct MockErrorParser: MarkdownParsing {
        func parse(_ markdown: String) async throws -> MarkdownContent {
            throw MarkdownError.parsingFailed
        }
    }

    @Test("El sistema debe manejar errores de parsing sin colapsar")
    func testErrorHandlingInFlow() async {
        let parser = MockErrorParser()
        let text = "Texto que fallará"
        
        // Simulamos la lógica que hace MarkdownView.performParse
        do {
            _ = try await parser.parse(text)
            Issue.record("El parser de error no debería haber tenido éxito")
        } catch {
            #expect(error is MarkdownError)
        }
    }

    @Test("El flujo de streaming debe procesar actualizaciones incrementales")
    func testStreamingLogicIntegration() async {
        // Simulamos una respuesta de LLM token por token
        let tokens = ["# ", "# He", "# Hello"]
        var currentText = ""
        
        for token in tokens {
            currentText += token
            // Simulamos el re-parseo que hace la vista con .onChange
            let parser = GFMParser()
            let content = try? await parser.parse(currentText)
            
            #expect(content != nil, "El parser falló durante el streaming en: \(currentText)")
        }
    }
}
