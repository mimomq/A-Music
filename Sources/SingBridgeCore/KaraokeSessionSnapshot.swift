import Foundation

public struct KaraokeSessionSnapshot: Codable, Equatable, Sendable {
  public var accompanimentPath: String?
  public var lyricsPath: String?
  public var lyricsOffsetSeconds: Double
  public var accompanimentVolume: Double

  public init(
    accompanimentPath: String? = nil,
    lyricsPath: String? = nil,
    lyricsOffsetSeconds: Double = 0,
    accompanimentVolume: Double = 0.8
  ) {
    self.accompanimentPath = accompanimentPath
    self.lyricsPath = lyricsPath
    self.lyricsOffsetSeconds = lyricsOffsetSeconds
    self.accompanimentVolume = accompanimentVolume
  }

  public static let empty = KaraokeSessionSnapshot()
}
