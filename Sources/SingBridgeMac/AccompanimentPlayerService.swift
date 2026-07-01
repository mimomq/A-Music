import Foundation
import SingBridgeCore

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
  private var progressTask: Task<Void, Never>?
  private var lastVolume = 0.8

  deinit {
    progressTask?.cancel()
  }

  func load(url: URL) {
    #if canImport(AVFoundation)
    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.delegate = self
      player.volume = Float(lastVolume)
      player.prepareToPlay()
      self.player = player
      publishState(isPlaying: false)
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
    startProgressUpdates()
    publishState(isPlaying: true)
    #endif
  }

  func pause() {
    #if canImport(AVFoundation)
    player?.pause()
    progressTask?.cancel()
    publishState(isPlaying: false)
    #endif
  }

  func stop() {
    #if canImport(AVFoundation)
    player?.stop()
    player?.currentTime = 0
    progressTask?.cancel()
    publishState(isPlaying: false)
    #endif
  }

  func setVolume(_ volume: Double) {
    #if canImport(AVFoundation)
    lastVolume = min(max(volume, 0), 1)
    player?.volume = Float(lastVolume)
    publishState(isPlaying: player?.isPlaying ?? false)
    #endif
  }

  func seek(to progress: Double) {
    #if canImport(AVFoundation)
    guard let player else { return }
    let clampedProgress = min(max(progress, 0), 1)
    player.currentTime = player.duration * clampedProgress
    publishState(isPlaying: player.isPlaying)
    #endif
  }

  private func publishState(isPlaying: Bool) {
    #if canImport(AVFoundation)
    guard let player else { return }
    onStateChange?(AccompanimentState(
      fileName: player.url?.lastPathComponent ?? "Local Track",
      isPlaying: isPlaying,
      volume: Double(player.volume),
      currentTime: player.currentTime,
      duration: player.duration
    ))
    #endif
  }

  private func startProgressUpdates() {
    progressTask?.cancel()
    progressTask = Task { [weak self] in
      while !Task.isCancelled {
        try? await Task.sleep(nanoseconds: 250_000_000)
        await MainActor.run {
          guard let self else { return }
          self.publishState(isPlaying: self.player?.isPlaying ?? false)
        }
      }
    }
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
  var currentTime: TimeInterval
  var duration: TimeInterval

  var progress: Double {
    guard duration > 0 else { return 0 }
    return min(max(currentTime / duration, 0), 1)
  }

  var elapsedText: String {
    TrackTimeFormatter.string(from: currentTime)
  }

  var durationText: String {
    TrackTimeFormatter.string(from: duration)
  }

  static let empty = AccompanimentState(
    fileName: nil,
    isPlaying: false,
    volume: 0.8,
    currentTime: 0,
    duration: 0
  )
}
