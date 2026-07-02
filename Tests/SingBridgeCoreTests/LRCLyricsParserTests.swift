import XCTest
@testable import SingBridgeCore

final class LRCLyricsParserTests: XCTestCase {
  func testParsesTimedLyricsAndSortsByTime() {
    let lines = LRCLyricsParser.parse("""
    [00:10.50]Second line
    [00:01.00]First line
    """)

    XCTAssertEqual(lines.map(\.text), ["First line", "Second line"])
    XCTAssertEqual(lines.map(\.time), [1, 10.5])
  }

  func testParsesMultipleTimestampsOnOneLine() {
    let lines = LRCLyricsParser.parse("[00:01.00][00:02.50]Echo")

    XCTAssertEqual(lines.count, 2)
    XCTAssertEqual(lines[0].text, "Echo")
    XCTAssertEqual(lines[1].time, 2.5)
  }

  func testFindsActiveLine() {
    let lines = LRCLyricsParser.parse("""
    [00:01.00]First
    [00:04.00]Second
    """)

    XCTAssertNil(LRCLyricsParser.activeLine(in: lines, at: 0.5))
    XCTAssertEqual(LRCLyricsParser.activeLine(in: lines, at: 2)?.text, "First")
    XCTAssertEqual(LRCLyricsParser.activeLine(in: lines, at: 5)?.text, "Second")
  }
}
