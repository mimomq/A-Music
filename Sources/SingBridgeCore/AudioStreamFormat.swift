import Foundation

public struct AudioStreamFormat: Equatable, Sendable {
  public var sampleRate: Double
  public var channelCount: Int
  public var bytesPerSample: Int

  public init(sampleRate: Double = 48_000, channelCount: Int = 1, bytesPerSample: Int = 4) {
    self.sampleRate = sampleRate
    self.channelCount = channelCount
    self.bytesPerSample = bytesPerSample
  }

  public init(settings: AudioSettings) {
    self.init(
      sampleRate: settings.normalized.sampleRate,
      channelCount: settings.normalized.channelCount,
      bytesPerSample: 4
    )
  }
}
