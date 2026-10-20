//
// HTML2MDIntegrationTests.swift
// HTML2MD
//
// Created by Peter Steinberger on 12/28/2025.
//

import Foundation
import Testing
@testable import HTML2MD

@MainActor
struct HTML2MDIntegrationTests {
    @Test("JavaScript libraries exist in bundle")
    func javaScriptLibrariesExist() {
        let bundle = Bundle.module
        #expect(bundle.path(forResource: "turndown.min", ofType: "js") != nil)
        #expect(bundle.path(forResource: "html-to-md.min", ofType: "js") != nil)
    }

    @Test("Turndown conversion works")
    func turndownConversion() async throws {
        let service = HTML2MD()
        let options = HTML2MDOptions(engine: .turndown)

        let markdown = try await service.convertToMarkdown("<p>Integration</p>", options: options)

        #expect(markdown.contains("Integration"))
    }

    @Test("html-to-md conversion works")
    func htmlToMdConversion() async throws {
        let service = HTML2MD()
        let options = HTML2MDOptions(engine: .htmlToMd)

        let markdown = try await service.convertToMarkdown("<p>Integration</p>", options: options)

        #expect(markdown.contains("Integration"))
    }
}
