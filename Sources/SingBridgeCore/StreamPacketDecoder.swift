import Foundation

public struct StreamPacketDecoder: Sendable {
  private var buffer = Data()

  public init() {}

  public mutating func append(_ data: Data) -> [AudioPacket] {
    buffer.append(data)
    var packets: [AudioPacket] = []

    while let packet = popPacket() {
      packets.append(packet)
    }

    return packets
  }

  public mutating func reset() {
    buffer.removeAll(keepingCapacity: true)
  }

  private mutating func popPacket() -> AudioPacket? {
    let lengthPrefixSize = MemoryLayout<UInt32>.size
    guard buffer.count >= lengthPrefixSize else { return nil }

    let payloadLength = Int(UInt32(bigEndianData: buffer.prefix(lengthPrefixSize)) ?? 0)
    guard payloadLength > 0 else {
      buffer.removeFirst(lengthPrefixSize)
      return nil
    }

    let frameLength = lengthPrefixSize + payloadLength
    guard buffer.count >= frameLength else { return nil }

    let packetStartIndex = buffer.index(buffer.startIndex, offsetBy: lengthPrefixSize)
    let packetEndIndex = buffer.index(packetStartIndex, offsetBy: payloadLength)
    let encodedPacket = buffer.subdata(in: packetStartIndex..<packetEndIndex)
    buffer.removeSubrange(buffer.startIndex..<packetEndIndex)
    return AudioPacket(encoded: encodedPacket)
  }
}

public enum StreamPacketEncoder {
  public static func frame(_ packet: AudioPacket) -> Data {
    let encodedPacket = packet.encoded()
    var length = UInt32(encodedPacket.count).bigEndian
    var frame = Data(bytes: &length, count: MemoryLayout<UInt32>.size)
    frame.append(encodedPacket)
    return frame
  }
}

private extension UInt32 {
  init?<Bytes: Collection>(bigEndianData bytes: Bytes) where Bytes.Element == UInt8 {
    guard bytes.count == MemoryLayout<UInt32>.size else { return nil }
    var value: UInt32 = 0
    for byte in bytes {
      value = (value << 8) | UInt32(byte)
    }
    self = value
  }
}
