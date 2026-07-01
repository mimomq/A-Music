import Foundation

public struct AppleMusicCatalogTrack: Equatable, Identifiable, Sendable {
  public var id: String
  public var title: String
  public var artistName: String
  public var albumTitle: String?
  public var artworkURL: URL?

  public init(
    id: String,
    title: String,
    artistName: String,
    albumTitle: String? = nil,
    artworkURL: URL? = nil
  ) {
    self.id = id
    self.title = title
    self.artistName = artistName
    self.albumTitle = albumTitle
    self.artworkURL = artworkURL
  }
}
