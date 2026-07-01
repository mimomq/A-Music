import Foundation

public enum TrackTimeFormatter {
  public static func string(from seconds: TimeInterval) -> String {
    guard seconds.isFinite, seconds > 0 else {
      return "0:00"
    }

    let totalSeconds = Int(seconds.rounded(.down))
    let minutes = totalSeconds / 60
    let remainingSeconds = totalSeconds % 60
    return "\(minutes):\(String(format: "%02d", remainingSeconds))"
  }
}
