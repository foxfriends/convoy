import XCTest
@testable import Convoy

final class ConvoyTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Convoy().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
