import Foundation

public struct AudioPacket: Equatable, Sendable {
  public static let magic = Data([0x53, 0x42, 0x52, 0x47])
  public static let version: UInt8 = 1
  private static let headerLength = 21

  public var sequenceNumber: UInt64
  public var sentAtNanoseconds: UInt64
  public var payload: Data

  public init(sequenceNumber: UInt64, sentAtNanoseconds: UInt64, payload: Data) {
    self.sequenceNumber = sequenceNumber
    self.sentAtNanoseconds = sentAtNanoseconds
    self.payload = payload
  }

  public func encoded() -> Data {
    var data = Data()
    data.append(Self.magic)
    data.append(Self.version)
    data.append(sequenceNumber.bigEndianData)
    data.append(sentAtNanoseconds.bigEndianData)
    data.append(payload)
    return data
  }

  public init?(encoded data: Data) {
    guard data.count >= Self.headerLength else { return nil }
    guard data.prefix(Self.magic.count) == Self.magic else { return nil }
    guard data[Self.magic.count] == Self.version else { return nil }

    let sequenceStart = Self.magic.count + 1
    let timestampStart = sequenceStart + MemoryLayout<UInt64>.size
    let payloadStart = timestampStart + MemoryLayout<UInt64>.size

    guard
      let sequenceNumber = UInt64(bigEndianData: data[sequenceStart..<timestampStart]),
      let sentAtNanoseconds = UInt64(bigEndianData: data[timestampStart..<payloadStart])
    else {
      return nil
    }

    self.sequenceNumber = sequenceNumber
    self.sentAtNanoseconds = sentAtNanoseconds
    self.payload = Data(data[payloadStart...])
  }
}

private extension UInt64 {
  var bigEndianData: Data {
    var value = bigEndian
    return Data(bytes: &value, count: MemoryLayout<UInt64>.size)
  }

  init?<Bytes: Collection>(bigEndianData bytes: Bytes) where Bytes.Element == UInt8 {
    guard bytes.count == MemoryLayout<UInt64>.size else { return nil }
    var value: UInt64 = 0
    for byte in bytes {
      value = (value << 8) | UInt64(byte)
    }
    self = value
  }
}
