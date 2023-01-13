import XCTest
@testable import get_weather

final class get_weatherTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(get_weather().text, "Hello, World!")
    }
}
