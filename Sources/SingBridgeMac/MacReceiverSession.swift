import Foundation
import SingBridgeCore

#if canImport(AVFoundation)
import AVFoundation
#endif

@MainActor
final class MacReceiverSession: ObservableObject {
  @Published var connectionState: ConnectionState = .idle
  @Published var settings = AudioSettings()
  @Published var levelMeter = LevelMeter.silent
  @Published var receivedPacketCount = 0
  @Published var droppedPacketCount = 0
  @Published var bufferedPacketCount = 0
  @Published var listenPort = String(SingBridgeNetworkDefaults.port)
  @Published var accompanimentState = AccompanimentState.empty
  @Published var isImportingAccompaniment = false
  @Published var isImportingLyrics = false
  @Published var lyricsFileName: String?
  @Published var lyricsLines: [LyricsLine] = []
  @Published var lyricsOffsetSeconds: Double = 0
  @Published var appleMusicQuery = ""
  @Published var appleMusicAuthorization = AppleMusicAuthorizationSummary(statusDescription: "Not requested", canSearchCatalog: false)
  @Published var appleMusicResults: [AppleMusicCatalogTrack] = []
  @Published var playingAppleMusicTrackID: AppleMusicCatalogTrack.ID?
  @Published var isSearchingAppleMusic = false
  @Published var isRunningSelfTest = false
  @Published var errorMessage: String?

  private var packetLossCounter = PacketLossCounter()
  private var jitterBuffer = AudioJitterBuffer(targetDepth: 3, maximumDepth: 12)
  private var selfTestTask: Task<Void, Never>?
  private let audioReceiver = NetworkAudioReceiver()
  private let audioPlayback = AudioPlaybackService()
  private let accompanimentPlayer = AccompanimentPlayerService()
  private let appleMusicCatalog = AppleMusicCatalogService()
  private let sessionStore = KaraokeSessionStore()

  init() {
    audioReceiver.onStateChange = { [weak self] state in
      Task { @MainActor [weak self] in
        self?.connectionState = state
      }
    }
    audioReceiver.onPacket = { [weak self] packet in
      Task { @MainActor [weak self] in
        self?.receive(packet: packet)
      }
    }
    audioReceiver.onError = { [weak self] message in
      Task { @MainActor [weak self] in
        self?.fail(message)
      }
    }
    audioPlayback.onError = { [weak self] message in
      Task { @MainActor [weak self] in
        self?.fail(message)
      }
    }
    accompanimentPlayer.onStateChange = { [weak self] state in
      self?.accompanimentState = state
    }
    accompanimentPlayer.onError = { [weak self] message in
      self?.fail(message)
    }
    appleMusicAuthorization = appleMusicCatalog.currentAuthorization()
    restoreSavedSession()
  }

  var diagnostics: ConnectionDiagnostics {
    ConnectionDiagnostics(
      state: connectionState,
      droppedPacketCount: droppedPacketCount,
      bufferedPacketCount: bufferedPacketCount
    )
  }

  var activeLyricsLine: LyricsLine? {
    LyricsTimeline.activeLine(
      in: lyricsLines,
      playbackTime: accompanimentState.currentTime,
      offset: lyricsOffsetSeconds
    )
  }

  var nextLyricsLine: LyricsLine? {
    LyricsTimeline.nextLine(
      in: lyricsLines,
      playbackTime: accompanimentState.currentTime,
      offset: lyricsOffsetSeconds
    )
  }

  func startListening() {
    do {
      errorMessage = nil
      connectionState = .searching
      try audioPlayback.start(format: AudioStreamFormat(settings: settings))
      try audioReceiver.start(port: UInt16(listenPort) ?? SingBridgeNetworkDefaults.port)
    } catch {
      fail(error.localizedDescription)
      stopListening()
    }
  }

  func stopListening() {
    audioReceiver.stop()
    audioPlayback.stop()
    stopSelfTest()
    connectionState = .idle
    levelMeter = .silent
    receivedPacketCount = 0
    droppedPacketCount = 0
    bufferedPacketCount = 0
    packetLossCounter.reset()
    jitterBuffer.reset()
  }

  func receive(encodedPacket data: Data) {
    guard let packet = AudioPacket(encoded: data) else {
      connectionState = .failed(message: "Invalid audio packet")
      return
    }

    receive(packet: packet)
  }

  func receive(packet: AudioPacket) {
    let level = LevelMeterCalculator.float32LevelMeter(for: packet.payload)

    packetLossCounter.record(sequenceNumber: packet.sequenceNumber)
    receivedPacketCount = packetLossCounter.receivedCount
    droppedPacketCount = packetLossCounter.droppedCount
    levelMeter = level
    jitterBuffer.enqueue(packet)
    bufferedPacketCount = jitterBuffer.count

    for readyPacket in jitterBuffer.drainReady() {
      audioPlayback.play(payload: readyPacket.payload, gain: settings.inputGain)
    }
    bufferedPacketCount = jitterBuffer.count

    if case .connected(let deviceName, _) = connectionState {
      let now = DispatchTime.now().uptimeNanoseconds
      let packetAge = now > packet.sentAtNanoseconds ? Int((now - packet.sentAtNanoseconds) / 1_000_000) : 0
      connectionState = .connected(deviceName: deviceName, latencyMilliseconds: packetAge)
    }
  }

  private func fail(_ message: String) {
    errorMessage = message
    connectionState = .failed(message: message)
  }

  func loadAccompaniment(url: URL) {
    accompanimentPlayer.load(url: url)
    saveSession(accompanimentURL: url)
  }

  func toggleAccompanimentPlayback() {
    if accompanimentState.isPlaying {
      accompanimentPlayer.pause()
    } else {
      accompanimentPlayer.play()
    }
  }

  func stopAccompaniment() {
    accompanimentPlayer.stop()
  }

  func setAccompanimentVolume(_ volume: Double) {
    accompanimentPlayer.setVolume(volume)
    saveSession()
  }

  func seekAccompaniment(to progress: Double) {
    accompanimentPlayer.seek(to: progress)
  }

  func loadLyrics(url: URL) {
    do {
      let content = try String(contentsOf: url, encoding: .utf8)
      lyricsLines = LRCLyricsParser.parse(content)
      lyricsFileName = url.lastPathComponent
      saveSession(lyricsURL: url)
    } catch {
      fail(error.localizedDescription)
    }
  }

  func setLyricsOffset(_ offset: Double) {
    lyricsOffsetSeconds = offset
    saveSession()
  }

  func requestAppleMusicAuthorization() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      appleMusicAuthorization = await appleMusicCatalog.requestAuthorization()
    }
  }

  func searchAppleMusic() {
    Task { @MainActor [weak self] in
      guard let self else { return }
      isSearchingAppleMusic = true
      defer { isSearchingAppleMusic = false }

      do {
        appleMusicResults = try await appleMusicCatalog.search(term: appleMusicQuery)
      } catch {
        fail(error.localizedDescription)
      }
    }
  }

  func playAppleMusic(track: AppleMusicCatalogTrack) {
    Task { @MainActor [weak self] in
      guard let self else { return }
      do {
        try await appleMusicCatalog.play(trackID: track.id)
        playingAppleMusicTrackID = track.id
      } catch {
        fail(error.localizedDescription)
      }
    }
  }

  func toggleSelfTest() {
    isRunningSelfTest ? stopSelfTest() : startSelfTest()
  }

  private func startSelfTest() {
    do {
      errorMessage = nil
      isRunningSelfTest = true
      connectionState = .connected(deviceName: "Self Test", latencyMilliseconds: 0)
      try audioPlayback.start(format: AudioStreamFormat(settings: settings))

      selfTestTask?.cancel()
      selfTestTask = Task { [weak self] in
        let packets = TestToneGenerator.packets(
          duration: 1.2,
          packetDuration: 0.02,
          sampleRate: self?.settings.sampleRate ?? 48_000,
          frequency: 440,
          startSequenceNumber: UInt64(self?.receivedPacketCount ?? 0),
          startTimestampNanoseconds: DispatchTime.now().uptimeNanoseconds
        )

        for packet in packets {
          if Task.isCancelled { return }
          await MainActor.run {
            self?.receive(packet: packet)
          }
          try? await Task.sleep(nanoseconds: 20_000_000)
        }

        await MainActor.run {
          self?.isRunningSelfTest = false
        }
      }
    } catch {
      fail(error.localizedDescription)
      isRunningSelfTest = false
    }
  }

  private func stopSelfTest() {
    selfTestTask?.cancel()
    selfTestTask = nil
    isRunningSelfTest = false
  }

  private func restoreSavedSession() {
    let snapshot = sessionStore.load()
    lyricsOffsetSeconds = snapshot.lyricsOffsetSeconds

    if let accompanimentPath = snapshot.accompanimentPath {
      let url = URL(fileURLWithPath: accompanimentPath)
      if FileManager.default.fileExists(atPath: url.path) {
        accompanimentPlayer.load(url: url)
      }
    }

    if let lyricsPath = snapshot.lyricsPath {
      let url = URL(fileURLWithPath: lyricsPath)
      if FileManager.default.fileExists(atPath: url.path) {
        loadLyrics(url: url)
      }
    }

    if snapshot.accompanimentVolume != accompanimentState.volume {
      accompanimentPlayer.setVolume(snapshot.accompanimentVolume)
    }
  }

  private func saveSession(accompanimentURL: URL? = nil, lyricsURL: URL? = nil) {
    let existing = sessionStore.load()
    let snapshot = KaraokeSessionSnapshot(
      accompanimentPath: accompanimentURL?.path ?? existing.accompanimentPath,
      lyricsPath: lyricsURL?.path ?? existing.lyricsPath,
      lyricsOffsetSeconds: lyricsOffsetSeconds,
      accompanimentVolume: accompanimentState.volume
    )
    sessionStore.save(snapshot)
  }
}
