import Foundation
import SingBridgeCore

#if canImport(AVFoundation)
import AVFoundation
#endif

final class MicrophoneCaptureService {
  var onAudioPayload: ((Data, LevelMeter) -> Void)?
  var onError: ((String) -> Void)?

  #if canImport(AVFoundation)
  private let engine = AVAudioEngine()
  #endif

  func start(settings: AudioSettings) throws {
    #if canImport(AVFoundation)
    let normalizedSettings = settings.normalized

    #if os(iOS)
    let audioSession = AVAudioSession.sharedInstance()
    try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .defaultToSpeaker])
    try audioSession.setPreferredSampleRate(normalizedSettings.sampleRate)
    try audioSession.setPreferredInputNumberOfChannels(normalizedSettings.channelCount)
    try audioSession.setActive(true)
    #endif

    let inputNode = engine.inputNode
    let inputFormat = inputNode.outputFormat(forBus: 0)
    inputNode.removeTap(onBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 960, format: inputFormat) { [weak self] buffer, _ in
      guard let self else { return }
      let payload = Self.float32MonoPayload(from: buffer, gain: Float(normalizedSettings.inputGain))
      let level = LevelMeterCalculator.float32LevelMeter(for: payload)
      self.onAudioPayload?(payload, level)
    }

    engine.prepare()
    try engine.start()
    #else
    throw MicrophoneCaptureError.unavailable
    #endif
  }

  func stop() {
    #if canImport(AVFoundation)
    engine.inputNode.removeTap(onBus: 0)
    engine.stop()

    #if os(iOS)
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    #endif
    #endif
  }

  #if canImport(AVFoundation)
  private static func float32MonoPayload(from buffer: AVAudioPCMBuffer, gain: Float) -> Data {
    guard let channelData = buffer.floatChannelData else {
      return Data()
    }

    let frameCount = Int(buffer.frameLength)
    let channelCount = Int(buffer.format.channelCount)
    guard frameCount > 0, channelCount > 0 else {
      return Data()
    }

    var monoSamples = [Float](repeating: 0, count: frameCount)
    for frameIndex in 0..<frameCount {
      var mixedSample: Float = 0
      for channelIndex in 0..<channelCount {
        mixedSample += channelData[channelIndex][frameIndex]
      }
      monoSamples[frameIndex] = (mixedSample / Float(channelCount)) * gain
    }

    return monoSamples.withUnsafeBufferPointer { Data(buffer: $0) }
  }
  #endif
}

enum MicrophoneCaptureError: LocalizedError {
  case unavailable

  var errorDescription: String? {
    "Microphone capture is unavailable on this platform."
  }
}
