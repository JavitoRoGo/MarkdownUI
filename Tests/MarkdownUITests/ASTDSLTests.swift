//
//  ASTDSLTests.swift
//  MarkdownUI
//
//  Created by Javier Rodríguez Gómez on 26/08/2026.
//


import Testing
import Foundation
@testable import MarkdownUI

@Suite("Fase 1: Tests de Lógica Pura (AST y Builders)")
struct ASTDSLTests {

    // MARK: - Block Builder Tests

    @Test("MarkdownContentBuilder debe combinar múltiples bloques en una secuencia plana")
    func testBlockBuilderFlattening() {
        let blocks = MarkdownContentBuilder.buildBlock(
            [BlockNode.thematicBreak],
			[BlockNode.paragraph([])]
        )
        
        #expect(blocks.count == 2)
    }

    @Test("El DSL de bloques debe permitir la creación de estructuras anidadas")
    func testNestedBlockStructure() {
		struct TestContainer {
			@MarkdownContentBuilder
			var content: [BlockNode] {
				BlockNode.blockquote {
					BlockNode.paragraph {
						"Texto anidado"
					}
				}
			}
		}

		let container = TestContainer()
		let content = container.content

        #expect(content.count == 1)
        if case .blockquote(let nestedBlocks) = content[0] {
            #expect(nestedBlocks.count == 1)
            if case .paragraph(let inlineNodes) = nestedBlocks[0] {
                #expect(inlineNodes.count == 1)
                #expect(inlineNodes[0] == .text("Texto anidado"))
            } else {
                Issue.record("El bloque dentro del blockquote no es un párrafo")
            }
        } else {
            Issue.record("El primer bloque no es un blockquote")
        }
    }

    // MARK: - Inline Builder Tests

    @Test("InlineContentBuilder debe convertir automáticamente Strings en nodos .text")
    func testInlineStringConversion() {
        let inlineNodes = InlineContentBuilder.buildExpression("Hola Mundo")
        
        #expect(inlineNodes.count == 1)
        #expect(inlineNodes[0] == .text("Hola Mundo"))
    }

    @Test("InlineContentBuilder debe combinar nodos de texto y estilos (strong/emphasis)")
    func testComplexInlineComposition() {
        // Simulamos: "Texto normal " + "**negrita**"
        let inline = InlineContentBuilder.buildBlock(
            [.text("Texto normal ")],
            [InlineNode.strong([.text("negrita")])]
        )

        #expect(inline.count == 2)
        #expect(inline[0] == .text("Texto normal "))
        if case .strong(let strongNodes) = inline[1] {
            #expect(strongNodes[0] == .text("negrita"))
        } else {
            Issue.record("El segundo nodo no es .strong")
        }
    }

    // MARK: - AST Logic Tests

    @Test("Los niveles de encabezado deben ser comparables jerárquicamente")
    func testHeadingLevelComparison() {
        #expect(BlockNode.HeadingLevel.h1 < BlockNode.HeadingLevel.h2)
        #expect(BlockNode.HeadingLevel.h3 > BlockNode.HeadingLevel.h2)
        #expect(BlockNode.HeadingLevel.h6 > BlockNode.HeadingLevel.h5)
    }

    @Test("ListItem debe almacenar correctamente el estado de una TaskList")
    func testListItemTaskStatus() {
        let checkedItem = ListItem(taskStatus: .checked, children: [])
        let uncheckedItem = ListItem(taskStatus: .unchecked, children: [])
        let regularItem = ListItem(taskStatus: nil, children: [])

        #expect(checkedItem.taskStatus == .checked)
        #expect(uncheckedItem.taskStatus == .unchecked)
        #expect(regularItem.taskStatus == nil)
    }
}
