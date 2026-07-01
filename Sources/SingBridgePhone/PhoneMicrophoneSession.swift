import Foundation
import SingBridgeCore

#if canImport(AVFoundation)
import AVFoundation
#endif

@MainActor
final class PhoneMicrophoneSession: ObservableObject {
  @Published var connectionState: ConnectionState = .idle
  @Published var settings = AudioSettings()
  @Published var levelMeter = LevelMeter.silent
  @Published var isCapturing = false

  private var sequenceNumber: UInt64 = 0

  func start() {
    isCapturing = true
    connectionState = .searching
  }

  func stop() {
    isCapturing = false
    levelMeter = .silent
    connectionState = .idle
  }

  func toggleMute() {
    settings.isMuted.toggle()
  }

  func makePacket(from payload: Data, sentAtNanoseconds: UInt64) -> AudioPacket {
    defer { sequenceNumber += 1 }
    return AudioPacket(
      sequenceNumber: sequenceNumber,
      sentAtNanoseconds: sentAtNanoseconds,
      payload: settings.isMuted ? Data() : payload
    )
  }
}
