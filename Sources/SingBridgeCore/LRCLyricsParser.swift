import Foundation

public enum LRCLyricsParser {
  public static func parse(_ content: String) -> [LyricsLine] {
    content
      .components(separatedBy: .newlines)
      .flatMap(parseLine)
      .sorted { lhs, rhs in
        if lhs.time == rhs.time {
          return lhs.text < rhs.text
        }
        return lhs.time < rhs.time
      }
  }

  public static func activeLine(in lines: [LyricsLine], at currentTime: TimeInterval) -> LyricsLine? {
    lines.last { $0.time <= currentTime }
  }

  private static func parseLine(_ line: String) -> [LyricsLine] {
    let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedLine.isEmpty else { return [] }

    var timestamps: [TimeInterval] = []
    var cursor = trimmedLine.startIndex

    while cursor < trimmedLine.endIndex, trimmedLine[cursor] == "[" {
      guard let closeIndex = trimmedLine[cursor...].firstIndex(of: "]") else { break }
      let timestampText = String(trimmedLine[trimmedLine.index(after: cursor)..<closeIndex])
      if let time = parseTimestamp(timestampText) {
        timestamps.append(time)
      }
      cursor = trimmedLine.index(after: closeIndex)
    }

    guard !timestamps.isEmpty else { return [] }
    let lyricText = trimmedLine[cursor...].trimmingCharacters(in: .whitespaces)
    guard !lyricText.isEmpty else { return [] }

    return timestamps.map { LyricsLine(time: $0, text: lyricText) }
  }

  private static func parseTimestamp(_ timestamp: String) -> TimeInterval? {
    let parts = timestamp.split(separator: ":", maxSplits: 1).map(String.init)
    guard parts.count == 2, let minutes = Double(parts[0]), let seconds = Double(parts[1]) else {
      return nil
    }
    return minutes * 60 + seconds
  }
}
