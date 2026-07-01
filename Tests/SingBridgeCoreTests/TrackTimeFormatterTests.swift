import XCTest
@testable import SingBridgeCore

final class TrackTimeFormatterTests: XCTestCase {
  func testFormatsZeroAndNegativeValues() {
    XCTAssertEqual(TrackTimeFormatter.string(from: 0), "0:00")
    XCTAssertEqual(TrackTimeFormatter.string(from: -4), "0:00")
  }

  func testFormatsMinutesAndSeconds() {
    XCTAssertEqual(TrackTimeFormatter.string(from: 65.9), "1:05")
    XCTAssertEqual(TrackTimeFormatter.string(from: 600), "10:00")
  }
}
