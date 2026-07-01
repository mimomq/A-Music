import Foundation

public struct LevelMeter: Equatable, Sendable {
  public var peak: Double
  public var average: Double

  public init(peak: Double = 0, average: Double = 0) {
    self.peak = peak.clamped(to: 0...1)
    self.average = average.clamped(to: 0...1)
  }

  public static let silent = LevelMeter()
}
