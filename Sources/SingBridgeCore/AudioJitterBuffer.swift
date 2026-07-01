import Foundation

public struct AudioJitterBuffer: Sendable {
  public private(set) var targetDepth: Int
  public private(set) var maximumDepth: Int
  private var packets: [AudioPacket] = []

  public init(targetDepth: Int = 3, maximumDepth: Int = 12) {
    self.targetDepth = max(1, targetDepth)
    self.maximumDepth = max(self.targetDepth, maximumDepth)
  }

  public var count: Int {
    packets.count
  }

  public var isReady: Bool {
    packets.count >= targetDepth
  }

  public mutating func enqueue(_ packet: AudioPacket) {
    if packets.contains(where: { $0.sequenceNumber == packet.sequenceNumber }) {
      return
    }

    packets.append(packet)
    packets.sort { $0.sequenceNumber < $1.sequenceNumber }

    if packets.count > maximumDepth {
      packets.removeFirst(packets.count - maximumDepth)
    }
  }

  public mutating func dequeueIfReady() -> AudioPacket? {
    guard isReady else { return nil }
    return packets.removeFirst()
  }

  public mutating func drainReady() -> [AudioPacket] {
    var readyPackets: [AudioPacket] = []
    while let packet = dequeueIfReady() {
      readyPackets.append(packet)
    }
    return readyPackets
  }

  public mutating func reset() {
    packets.removeAll(keepingCapacity: true)
  }
}
