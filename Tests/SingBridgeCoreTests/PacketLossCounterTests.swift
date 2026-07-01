import XCTest
@testable import SingBridgeCore

final class PacketLossCounterTests: XCTestCase {
  func testCountsDroppedPacketsBetweenSequences() {
    var counter = PacketLossCounter()

    counter.record(sequenceNumber: 10)
    counter.record(sequenceNumber: 11)
    counter.record(sequenceNumber: 15)

    XCTAssertEqual(counter.receivedCount, 3)
    XCTAssertEqual(counter.droppedCount, 3)
  }

  func testResetClearsState() {
    var counter = PacketLossCounter()

    counter.record(sequenceNumber: 1)
    counter.record(sequenceNumber: 3)
    counter.reset()
    counter.record(sequenceNumber: 10)

    XCTAssertEqual(counter.receivedCount, 1)
    XCTAssertEqual(counter.droppedCount, 0)
  }
}
