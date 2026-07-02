import XCTest
@testable import SingBridgeCore

final class TestToneGeneratorTests: XCTestCase {
  func testGeneratesExpectedFloat32PayloadSize() {
    let payload = TestToneGenerator.float32SineWavePayload(
      duration: 0.1,
      sampleRate: 1_000
    )

    XCTAssertEqual(payload.count, 100 * MemoryLayout<Float>.size)
  }

  func testGeneratesOrderedPackets() {
    let packets = TestToneGenerator.packets(
      duration: 0.05,
      packetDuration: 0.02,
      sampleRate: 1_000,
      startSequenceNumber: 10
    )

    XCTAssertEqual(packets.map(\.sequenceNumber), [10, 11, 12])
    XCTAssertFalse(packets.contains { $0.payload.isEmpty })
  }
}
