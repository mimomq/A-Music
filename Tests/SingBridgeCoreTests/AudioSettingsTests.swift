import XCTest
@testable import SingBridgeCore

final class AudioSettingsTests: XCTestCase {
  func testNormalizationKeepsValuesInSupportedRanges() {
    let settings = AudioSettings(
      sampleRate: 192_000,
      channelCount: 8,
      inputGain: 4,
      monitorMix: -1,
      targetLatencyMilliseconds: 5,
      isMuted: true
    ).normalized

    XCTAssertEqual(settings.sampleRate, 96_000)
    XCTAssertEqual(settings.channelCount, 2)
    XCTAssertEqual(settings.inputGain, 2)
    XCTAssertEqual(settings.monitorMix, 0)
    XCTAssertEqual(settings.targetLatencyMilliseconds, 20)
    XCTAssertTrue(settings.isMuted)
  }
}
