import Foundation

public enum LyricsTimeline {
  public static func activeLine(
    in lines: [LyricsLine],
    playbackTime: TimeInterval,
    offset: TimeInterval
  ) -> LyricsLine? {
    LRCLyricsParser.activeLine(in: lines, at: playbackTime + offset)
  }

  public static func nextLine(
    in lines: [LyricsLine],
    playbackTime: TimeInterval,
    offset: TimeInterval
  ) -> LyricsLine? {
    lines.first { $0.time > playbackTime + offset }
  }
}
