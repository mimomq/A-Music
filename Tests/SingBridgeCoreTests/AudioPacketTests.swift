import Foundation
import XCTest
@testable import SingBridgeCore

final class AudioPacketTests: XCTestCase {
  func testRoundTripEncoding() {
    let packet = AudioPacket(
      sequenceNumber: 42,
      sentAtNanoseconds: 123_456_789,
      payload: Data([1, 2, 3, 4])
    )

    XCTAssertEqual(AudioPacket(encoded: packet.encoded()), packet)
  }

  func testRejectsInvalidMagic() {
    let data = Data([0, 0, 0, 0, 1, 2, 3])
    XCTAssertNil(AudioPacket(encoded: data))
  }
}
