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
  @Published var bufferedPacketCount = 0
  @Published var listenPort = String(SingBridgeNetworkDefaults.port)
  @Published var errorMessage: String?

  private var packetLossCounter = PacketLossCounter()
  private var jitterBuffer = AudioJitterBuffer(targetDepth: 3, maximumDepth: 12)
  private let audioReceiver = NetworkAudioReceiver()
  private let audioPlayback = AudioPlaybackService()

  init() {
    audioReceiver.onStateChange = { [weak self] state in
      Task { @MainActor [weak self] in
        self?.connectionState = state
      }
    }
    audioReceiver.onPacket = { [weak self] packet in
      Task { @MainActor [weak self] in
        self?.receive(packet: packet)
      }
    }
    audioReceiver.onError = { [weak self] message in
      Task { @MainActor [weak self] in
        self?.fail(message)
      }
    }
    audioPlayback.onError = { [weak self] message in
      Task { @MainActor [weak self] in
        self?.fail(message)
      }
    }
  }

  func startListening() {
    do {
      errorMessage = nil
      connectionState = .searching
      try audioPlayback.start(format: AudioStreamFormat(settings: settings))
      try audioReceiver.start(port: UInt16(listenPort) ?? SingBridgeNetworkDefaults.port)
    } catch {
      fail(error.localizedDescription)
      stopListening()
    }
  }

  func stopListening() {
    audioReceiver.stop()
    audioPlayback.stop()
    connectionState = .idle
    levelMeter = .silent
    receivedPacketCount = 0
    droppedPacketCount = 0
    bufferedPacketCount = 0
    packetLossCounter.reset()
    jitterBuffer.reset()
  }

  func receive(encodedPacket data: Data) {
    guard let packet = AudioPacket(encoded: data) else {
      connectionState = .failed(message: "Invalid audio packet")
      return
    }

    receive(packet: packet)
  }

  func receive(packet: AudioPacket) {
    let level = LevelMeterCalculator.float32LevelMeter(for: packet.payload)

    packetLossCounter.record(sequenceNumber: packet.sequenceNumber)
    receivedPacketCount = packetLossCounter.receivedCount
    droppedPacketCount = packetLossCounter.droppedCount
    levelMeter = level
    jitterBuffer.enqueue(packet)
    bufferedPacketCount = jitterBuffer.count

    for readyPacket in jitterBuffer.drainReady() {
      audioPlayback.play(payload: readyPacket.payload, gain: settings.inputGain)
    }
    bufferedPacketCount = jitterBuffer.count

    if case .connected(let deviceName, _) = connectionState {
      let now = DispatchTime.now().uptimeNanoseconds
      let packetAge = now > packet.sentAtNanoseconds ? Int((now - packet.sentAtNanoseconds) / 1_000_000) : 0
      connectionState = .connected(deviceName: deviceName, latencyMilliseconds: packetAge)
    }
  }

  private func fail(_ message: String) {
    errorMessage = message
    connectionState = .failed(message: message)
  }
}
