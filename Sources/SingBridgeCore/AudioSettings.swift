import Foundation

public struct AudioSettings: Equatable, Sendable {
  public var sampleRate: Double
  public var channelCount: Int
  public var inputGain: Double
  public var monitorMix: Double
  public var targetLatencyMilliseconds: Int
  public var isMuted: Bool

  public init(
    sampleRate: Double = 48_000,
    channelCount: Int = 1,
    inputGain: Double = 1,
    monitorMix: Double = 0.8,
    targetLatencyMilliseconds: Int = 45,
    isMuted: Bool = false
  ) {
    self.sampleRate = sampleRate
    self.channelCount = channelCount
    self.inputGain = inputGain
    self.monitorMix = monitorMix
    self.targetLatencyMilliseconds = targetLatencyMilliseconds
    self.isMuted = isMuted
  }

  public var normalized: AudioSettings {
    AudioSettings(
      sampleRate: sampleRate.clamped(to: 8_000...96_000),
      channelCount: channelCount.clamped(to: 1...2),
      inputGain: inputGain.clamped(to: 0...2),
      monitorMix: monitorMix.clamped(to: 0...1),
      targetLatencyMilliseconds: targetLatencyMilliseconds.clamped(to: 20...150),
      isMuted: isMuted
    )
  }
}
