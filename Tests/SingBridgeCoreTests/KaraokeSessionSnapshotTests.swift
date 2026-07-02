import XCTest
@testable import SingBridgeCore

final class KaraokeSessionSnapshotTests: XCTestCase {
  func testCodableRoundTrip() throws {
    let snapshot = KaraokeSessionSnapshot(
      accompanimentPath: "/tmp/song.m4a",
      lyricsPath: "/tmp/song.lrc",
      lyricsOffsetSeconds: -0.25,
      accompanimentVolume: 0.7
    )

    let data = try JSONEncoder().encode(snapshot)
    let decoded = try JSONDecoder().decode(KaraokeSessionSnapshot.self, from: data)

    XCTAssertEqual(decoded, snapshot)
  }
}
