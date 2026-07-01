import Foundation
import XCTest
@testable import SingBridgeCore

final class AudioJitterBufferTests: XCTestCase {
  func testWaitsForTargetDepthBeforeDequeuing() {
    var buffer = AudioJitterBuffer(targetDepth: 2, maximumDepth: 4)

    buffer.enqueue(packet(sequenceNumber: 1))
    XCTAssertNil(buffer.dequeueIfReady())

    buffer.enqueue(packet(sequenceNumber: 2))
    XCTAssertEqual(buffer.dequeueIfReady()?.sequenceNumber, 1)
  }

  func testOrdersPacketsBySequenceNumber() {
    var buffer = AudioJitterBuffer(targetDepth: 2, maximumDepth: 4)

    buffer.enqueue(packet(sequenceNumber: 3))
    buffer.enqueue(packet(sequenceNumber: 1))
    buffer.enqueue(packet(sequenceNumber: 2))

    XCTAssertEqual(buffer.dequeueIfReady()?.sequenceNumber, 1)
    XCTAssertEqual(buffer.dequeueIfReady()?.sequenceNumber, 2)
  }

  func testDropsOldestPacketsBeyondMaximumDepth() {
    var buffer = AudioJitterBuffer(targetDepth: 1, maximumDepth: 2)

    buffer.enqueue(packet(sequenceNumber: 1))
    buffer.enqueue(packet(sequenceNumber: 2))
    buffer.enqueue(packet(sequenceNumber: 3))

    XCTAssertEqual(buffer.count, 2)
    XCTAssertEqual(buffer.dequeueIfReady()?.sequenceNumber, 2)
  }

  private func packet(sequenceNumber: UInt64) -> AudioPacket {
    AudioPacket(sequenceNumber: sequenceNumber, sentAtNanoseconds: 0, payload: Data([1]))
  }
}
