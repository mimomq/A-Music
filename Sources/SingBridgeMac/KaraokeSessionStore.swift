import Foundation
import SingBridgeCore

final class KaraokeSessionStore {
  private let fileURL: URL

  init(fileURL: URL? = nil) {
    if let fileURL {
      self.fileURL = fileURL
    } else {
      let supportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        ?? FileManager.default.temporaryDirectory
      self.fileURL = supportURL
        .appendingPathComponent("SingBridge", isDirectory: true)
        .appendingPathComponent("karaoke-session.json")
    }
  }

  func load() -> KaraokeSessionSnapshot {
    do {
      let data = try Data(contentsOf: fileURL)
      return try JSONDecoder().decode(KaraokeSessionSnapshot.self, from: data)
    } catch {
      return .empty
    }
  }

  func save(_ snapshot: KaraokeSessionSnapshot) {
    do {
      try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      let data = try JSONEncoder().encode(snapshot)
      try data.write(to: fileURL, options: .atomic)
    } catch {
      // Persistence is a convenience feature; session controls should keep working if saving fails.
    }
  }
}
