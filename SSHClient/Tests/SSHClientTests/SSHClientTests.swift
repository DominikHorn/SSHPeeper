import XCTest
@testable import SSHClient

final class SSHClientTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SSHClient().text, "Hello, World!")
    }
}
