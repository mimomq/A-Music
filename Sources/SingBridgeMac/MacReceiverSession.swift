import Foundation
import SingBridgeCore

#if canImport(AVFoundation)
import AVFoundation
#endif

@MainActor
final class MacReceiverSession: ObservableObject {
  @Published var connectionState: ConnectionState = .idle
  @Published var settings = AudioSettings()
  @Published var levelMeter = LevelMeter.silent
  @Published var receivedPacketCount = 0
  @Published var droppedPacketCount = 0

  private var packetLossCounter = PacketLossCounter()

  func startListening() {
    connectionState = .searching
  }

  func stopListening() {
    connectionState = .idle
    levelMeter = .silent
    receivedPacketCount = 0
    droppedPacketCount = 0
    packetLossCounter.reset()
  }

  func receive(encodedPacket data: Data) {
    guard let packet = AudioPacket(encoded: data) else {
      connectionState = .failed(message: "Invalid audio packet")
      return
    }

    packetLossCounter.record(sequenceNumber: packet.sequenceNumber)
    receivedPacketCount = packetLossCounter.receivedCount
    droppedPacketCount = packetLossCounter.droppedCount
  }
}
