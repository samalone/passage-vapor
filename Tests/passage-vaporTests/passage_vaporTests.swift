import XCTest
@testable import Passage

final class passage_vaporTests: XCTestCase {
    func testSnippet() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let passage = Passage(appID: "KnLF0eFlF4tldSAunTIWQrXq",
                              publicKey: "LS0tLS1CRUdJTiBSU0EgUFVCTElDIEtFWS0tLS0tCk1JSUJDZ0tDQVFFQXl1N3JTMnZFN2pMa0x0a1lRaUtMWStJYjdVMTgwUzQrSlFuQ3NxVFU5WEU1WS9URGYrYlQKWXM4QVVoQW4zYlA1SXpnYU9sRWxzdEh0cE5MZDU3bmZTSUR2MGcraE8yL3c2MGFLdGRDY0F3K2ZIYlRRaGU4OQp4QnkvMW91SkhDQ3U5WVE3UjRQWGZXcUt4NC8reU1xZ3g1aytSbnhxWk5JVDZUSjJFdDVDTEY5STZJMDhjTEVXCllkL29Tc2YyVStKMEE4LzVHYkVSZUYrOW1OQUVHVWNLM095djdMQlB1Y3lyaDV3WTlwQXhyYWVReDlPdnpGdnYKSXpKdEsyWGErNE5hNnhqWHEzNFFXa2Jqc2JXOHBoWjRzaXJtdkNsSXI2TGdsQ1M2UU1zZkJZSCtZZmwva0xSVApvVkNmYVh0RFJ4VmFMdmJWM2FxV2QvMDBVNXdLTFNUTXZ3SURBUUFCCi0tLS0tRU5EIFJTQSBQVUJMSUMgS0VZLS0tLS0K")
        print(passage.authSnippet)
        XCTAssertEqual(passage.authSnippet,
            """
                <passage-auth app-id="KnLF0eFlF4tldSAunTIWQrXq"></passage-auth>
                <script src="https://psg.so/web.js"></script>
            """)
    }
}
