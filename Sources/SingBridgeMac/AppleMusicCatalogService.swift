import Foundation
import SingBridgeCore

#if canImport(MusicKit)
import MusicKit
#endif

@MainActor
final class AppleMusicCatalogService {
  #if canImport(MusicKit)
  private var songsByID: [String: Song] = [:]
  #endif

  func requestAuthorization() async -> AppleMusicAuthorizationSummary {
    #if canImport(MusicKit)
    let status = await MusicAuthorization.request()
    return AppleMusicAuthorizationSummary(statusDescription: status.displayText, canSearchCatalog: status == .authorized)
    #else
    return AppleMusicAuthorizationSummary(statusDescription: "MusicKit unavailable", canSearchCatalog: false)
    #endif
  }

  func currentAuthorization() -> AppleMusicAuthorizationSummary {
    #if canImport(MusicKit)
    let status = MusicAuthorization.currentStatus
    return AppleMusicAuthorizationSummary(statusDescription: status.displayText, canSearchCatalog: status == .authorized)
    #else
    return AppleMusicAuthorizationSummary(statusDescription: "MusicKit unavailable", canSearchCatalog: false)
    #endif
  }

  func search(term: String) async throws -> [AppleMusicCatalogTrack] {
    let trimmedTerm = term.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedTerm.isEmpty else { return [] }

    #if canImport(MusicKit)
    var request = MusicCatalogSearchRequest(term: trimmedTerm, types: [Song.self])
    request.limit = 12
    let response = try await request.response()
    songsByID = Dictionary(uniqueKeysWithValues: response.songs.map { ($0.id.rawValue, $0) })
    return response.songs.map { song in
      AppleMusicCatalogTrack(
        id: song.id.rawValue,
        title: song.title,
        artistName: song.artistName,
        albumTitle: song.albumTitle,
        artworkURL: song.artwork?.url(width: 120, height: 120)
      )
    }
    #else
    return []
    #endif
  }

  func play(trackID: String) async throws {
    #if canImport(MusicKit)
    guard let song = songsByID[trackID] else {
      throw AppleMusicCatalogError.trackNotLoaded
    }

    let player = ApplicationMusicPlayer.shared
    player.queue = [song]
    try await player.play()
    #endif
  }
}

enum AppleMusicCatalogError: LocalizedError {
  case trackNotLoaded

  var errorDescription: String? {
    switch self {
    case .trackNotLoaded:
      "Search for this Apple Music track again before playing it."
    }
  }
}

struct AppleMusicAuthorizationSummary: Equatable {
  var statusDescription: String
  var canSearchCatalog: Bool
}

#if canImport(MusicKit)
private extension MusicAuthorization.Status {
  var displayText: String {
    switch self {
    case .authorized:
      "Authorized"
    case .denied:
      "Denied"
    case .notDetermined:
      "Not requested"
    case .restricted:
      "Restricted"
    @unknown default:
      "Unknown"
    }
  }
}
#endif
