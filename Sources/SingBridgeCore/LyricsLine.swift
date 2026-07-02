import Foundation

public struct LyricsLine: Equatable, Identifiable, Sendable {
  public var id: String
  public var time: TimeInterval
  public var text: String

  public init(time: TimeInterval, text: String) {
    self.time = time
    self.text = text
    self.id = "\(time)-\(text)"
  }
}
