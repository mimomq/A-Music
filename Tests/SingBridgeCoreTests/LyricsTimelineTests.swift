import XCTest
@testable import SingBridgeCore

final class LyricsTimelineTests: XCTestCase {
  func testAppliesOffsetWhenFindingActiveLine() {
    let lines = LRCLyricsParser.parse("""
    [00:01.00]First
    [00:03.00]Second
    """)

    XCTAssertEqual(LyricsTimeline.activeLine(in: lines, playbackTime: 2, offset: 0)?.text, "First")
    XCTAssertEqual(LyricsTimeline.activeLine(in: lines, playbackTime: 2, offset: 1.1)?.text, "Second")
  }

  func testAppliesOffsetWhenFindingNextLine() {
    let lines = LRCLyricsParser.parse("""
    [00:01.00]First
    [00:03.00]Second
    """)

    XCTAssertEqual(LyricsTimeline.nextLine(in: lines, playbackTime: 0, offset: 0)?.text, "First")
    XCTAssertEqual(LyricsTimeline.nextLine(in: lines, playbackTime: 0, offset: 1.1)?.text, "Second")
  }
}
