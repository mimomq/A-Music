import Foundation
import SingBridgeCore

#if canImport(AVFoundation)
import AVFoundation
#endif

final class AudioPlaybackService {
  var onError: ((String) -> Void)?

  #if canImport(AVFoundation)
  private let engine = AVAudioEngine()
  private let playerNode = AVAudioPlayerNode()
  private var outputFormat = AVAudioFormat(
    commonFormat: .pcmFormatFloat32,
    sampleRate: 48_000,
    channels: 1,
    interleaved: false
  )
  #endif

  func start(format: AudioStreamFormat = AudioStreamFormat()) throws {
    #if canImport(AVFoundation)
    outputFormat = AVAudioFormat(
      commonFormat: .pcmFormatFloat32,
      sampleRate: format.sampleRate,
      channels: AVAudioChannelCount(format.channelCount),
      interleaved: false
    )

    guard let outputFormat else {
      throw AudioPlaybackError.invalidFormat
    }

    if !engine.attachedNodes.contains(playerNode) {
      engine.attach(playerNode)
    }

    engine.connect(playerNode, to: engine.mainMixerNode, format: outputFormat)
    engine.prepare()
    try engine.start()
    playerNode.play()
    #else
    throw AudioPlaybackError.unavailable
    #endif
  }

  func play(payload: Data, gain: Double) {
    #if canImport(AVFoundation)
    guard let outputFormat, let buffer = Self.buffer(from: payload, format: outputFormat, gain: Float(gain)) else {
      return
    }
    playerNode.scheduleBuffer(buffer, completionHandler: nil)
    #endif
  }

  func stop() {
    #if canImport(AVFoundation)
    playerNode.stop()
    engine.stop()
    #endif
  }

  #if canImport(AVFoundation)
  private static func buffer(from payload: Data, format: AVAudioFormat, gain: Float) -> AVAudioPCMBuffer? {
    let sampleCount = payload.count / MemoryLayout<Float>.size
    guard sampleCount > 0 else { return nil }
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleCount)) else {
      return nil
    }

    buffer.frameLength = AVAudioFrameCount(sampleCount)
    guard let destination = buffer.floatChannelData?[0] else { return nil }

    payload.withUnsafeBytes { rawBuffer in
      let source = rawBuffer.bindMemory(to: Float.self)
      for index in 0..<sampleCount {
        destination[index] = source[index] * gain
      }
    }

    return buffer
  }
  #endif
}

enum AudioPlaybackError: LocalizedError {
  case invalidFormat
  case unavailable

  var errorDescription: String? {
    switch self {
    case .invalidFormat:
      "The requested audio playback format is invalid."
    case .unavailable:
      "Audio playback is unavailable on this platform."
    }
  }
}
