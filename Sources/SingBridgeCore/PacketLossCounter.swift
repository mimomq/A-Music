import Foundation

public struct PacketLossCounter: Equatable, Sendable {
  public private(set) var receivedCount = 0
  public private(set) var droppedCount = 0
  private var lastSequenceNumber: UInt64?

  public init() {}

  public mutating func record(sequenceNumber: UInt64) {
    if let lastSequenceNumber, sequenceNumber > lastSequenceNumber + 1 {
      droppedCount += Int(sequenceNumber - lastSequenceNumber - 1)
    }

    lastSequenceNumber = sequenceNumber
    receivedCount += 1
  }

  public mutating func reset() {
    receivedCount = 0
    droppedCount = 0
    lastSequenceNumber = nil
  }
}
