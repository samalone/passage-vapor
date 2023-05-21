import XCTest
@testable import Passage

final class passage_vaporTests: XCTestCase {
    func testSnippet() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let passage = Passage(appID: "KnLF0eFlF4tldSAunTIWQrXq")
        print(passage.authSnippet)
        XCTAssertEqual(passage.authSnippet,
            """
                <passage-auth app-id="KnLF0eFlF4tldSAunTIWQrXq"></passage-auth>
                <script src="https://psg.so/web.js"></script>
            """)
    }
}
