import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

@MainActor
final class AccompanimentPlayerService: NSObject {
  var onStateChange: ((AccompanimentState) -> Void)?
  var onError: ((String) -> Void)?

  #if canImport(AVFoundation)
  private var player: AVAudioPlayer?
  #endif

  func load(url: URL) {
    #if canImport(AVFoundation)
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.delegate = self
      player.prepareToPlay()
      self.player = player
      onStateChange?(AccompanimentState(fileName: url.lastPathComponent, isPlaying: false, volume: Double(player.volume)))
    } catch {
      onError?(error.localizedDescription)
    }
    #else
    onError?("Local accompaniment playback is unavailable on this platform.")
    #endif
  }

  func play() {
    #if canImport(AVFoundation)
    player?.play()
    publishState(isPlaying: true)
    #endif
  }

  func pause() {
    #if canImport(AVFoundation)
    player?.pause()
    publishState(isPlaying: false)
    #endif
  }

  func stop() {
    #if canImport(AVFoundation)
    player?.stop()
    player?.currentTime = 0
    publishState(isPlaying: false)
    #endif
  }

  func setVolume(_ volume: Double) {
    #if canImport(AVFoundation)
    player?.volume = Float(min(max(volume, 0), 1))
    publishState(isPlaying: player?.isPlaying ?? false)
    #endif
  }

  private func publishState(isPlaying: Bool) {
    #if canImport(AVFoundation)
    guard let player else { return }
    onStateChange?(AccompanimentState(
      fileName: player.url?.lastPathComponent ?? "Local Track",
      isPlaying: isPlaying,
      volume: Double(player.volume)
    ))
    #endif
  }
}

#if canImport(AVFoundation)
extension AccompanimentPlayerService: AVAudioPlayerDelegate {
  nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    Task { @MainActor [weak self] in
      self?.publishState(isPlaying: false)
    }
  }
}
#endif

struct AccompanimentState: Equatable {
  var fileName: String?
  var isPlaying: Bool
  var volume: Double

  static let empty = AccompanimentState(fileName: nil, isPlaying: false, volume: 0.8)
}
