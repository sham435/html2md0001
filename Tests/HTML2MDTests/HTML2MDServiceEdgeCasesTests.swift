import Testing
@testable import HTML2MD

@MainActor
struct HTML2MDServiceEdgeCasesTests {
    @Test("Empty input throws emptyResult")
    func emptyInputThrows() async {
        let service = HTML2MD()

        do {
            _ = try await service.convertToMarkdown("")
            #expect(Bool(false), "Expected HTML2MDError.emptyResult for empty input")
        } catch HTML2MDError.emptyResult {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }

    @Test("Whitespace input throws emptyResult")
    func whitespaceInputThrows() async {
        let service = HTML2MD()

        do {
            _ = try await service.convertToMarkdown("   \n\t  ")
            #expect(Bool(false), "Expected HTML2MDError.emptyResult for whitespace input")
        } catch HTML2MDError.emptyResult {
            #expect(Bool(true))
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }

    @Test("Malformed HTML preserves content")
    func malformedHTMLPreservesContent() async throws {
        let service = HTML2MD()
        let html = "<p>Unclosed paragraph <strong>bold text"

        let markdown = try await service.convertToMarkdown(html)

        #expect(markdown.contains("Unclosed paragraph"))
        #expect(markdown.contains("bold text"))
    }

    @Test("Script and style content is removed (Turndown)")
    func scriptAndStyleRemoval() async throws {
        let service = HTML2MD()
        let html = """
        <div>
            <p>Visible content</p>
            <script>alert('This should be removed');</script>
            <style>body { color: red; }</style>
            <p>More visible content</p>
        </div>
        """

        let markdown = try await service.convertToMarkdown(html, options: HTML2MDOptions(engine: .turndown))

        #expect(markdown.contains("Visible content"))
        #expect(markdown.contains("More visible content"))
        #expect(!markdown.contains("alert"))
        #expect(!markdown.contains("body { color: red; }"))
    }
}
