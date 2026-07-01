import Foundation
import XCTest
@testable import SingBridgeCore

final class StreamPacketDecoderTests: XCTestCase {
  func testDecodesLengthPrefixedPacketsAcrossChunks() {
    let first = AudioPacket(sequenceNumber: 1, sentAtNanoseconds: 10, payload: Data([1, 2]))
    let second = AudioPacket(sequenceNumber: 2, sentAtNanoseconds: 20, payload: Data([3, 4]))
    let stream = StreamPacketEncoder.frame(first) + StreamPacketEncoder.frame(second)

    var decoder = StreamPacketDecoder()
    let splitIndex = stream.index(stream.startIndex, offsetBy: 7)

    XCTAssertTrue(decoder.append(Data(stream[..<splitIndex])).isEmpty)
    XCTAssertEqual(decoder.append(Data(stream[splitIndex...])), [first, second])
  }
}
