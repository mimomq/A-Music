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
  @Published var macHost = "127.0.0.1"
  @Published var errorMessage: String?

  private var sequenceNumber: UInt64 = 0
  private let microphoneCapture = MicrophoneCaptureService()
  private let audioSender = NetworkAudioSender()

  init() {
    microphoneCapture.onAudioPayload = { [weak self] payload, level in
      Task { @MainActor [weak self] in
        self?.handleCapturedPayload(payload, level: level)
      }
    }
    microphoneCapture.onError = { [weak self] message in
      Task { @MainActor [weak self] in
        self?.fail(message)
      }
    }

    audioSender.onStateChange = { [weak self] state in
      Task { @MainActor [weak self] in
        self?.connectionState = state
      }
    }
    audioSender.onError = { [weak self] message in
      Task { @MainActor [weak self] in
        self?.fail(message)
      }
    }
  }

  func start() {
    do {
      errorMessage = nil
      isCapturing = true
      connectionState = .connecting(deviceName: macHost)
      audioSender.connect(host: macHost)
      try microphoneCapture.start(settings: settings)
    } catch {
      fail(error.localizedDescription)
      stop()
    }
  }

  func stop() {
    microphoneCapture.stop()
    audioSender.stop()
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

  private func handleCapturedPayload(_ payload: Data, level: LevelMeter) {
    levelMeter = settings.isMuted ? .silent : level
    let packet = makePacket(from: payload, sentAtNanoseconds: DispatchTime.now().uptimeNanoseconds)
    audioSender.send(packet: packet)
  }

  private func fail(_ message: String) {
    errorMessage = message
    connectionState = .failed(message: message)
    isCapturing = false
  }
}
