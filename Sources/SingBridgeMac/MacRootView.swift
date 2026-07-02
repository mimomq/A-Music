import SingBridgeCore
import SwiftUI
import UniformTypeIdentifiers

struct MacRootView: View {
  @ObservedObject var session: MacReceiverSession
  @AppStorage(AppLanguage.storageKey) private var selectedLanguageValue = AppLanguage.english.rawValue

  private var language: AppLanguage {
    AppLanguage.fromStorageValue(selectedLanguageValue)
  }

  private var strings: AppStrings {
    AppStrings(language: language)
  }

  var body: some View {
    NavigationSplitView {
      List {
        Label(strings.receiver, systemImage: "dot.radiowaves.left.and.right")
        Label(strings.voice, systemImage: "waveform")
        Label(strings.music, systemImage: "music.note")
        Label(strings.settings, systemImage: "gearshape")
      }
      .navigationTitle("SingBridge")
    } detail: {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          header
          languagePanel
          transportPanel
          diagnosticsPanel
          voicePanel
          accompanimentPanel
          lyricsPanel
          appleMusicPanel
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
    .fileImporter(
      isPresented: Binding(
        get: { session.isImportingAccompaniment },
        set: { session.isImportingAccompaniment = $0 }
      ),
      allowedContentTypes: [.audio],
      allowsMultipleSelection: false
    ) { result in
      if case .success(let urls) = result, let url = urls.first {
        session.loadAccompaniment(url: url)
      }
    }
    .fileImporter(
      isPresented: Binding(
        get: { session.isImportingLyrics },
        set: { session.isImportingLyrics = $0 }
      ),
      allowedContentTypes: [.plainText],
      allowsMultipleSelection: false
    ) { result in
      if case .success(let urls) = result, let url = urls.first {
        session.loadLyrics(url: url)
      }
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(strings.karaokeReceiver)
        .font(.largeTitle.weight(.bold))
      Text(strings.connectionState(session.connectionState))
        .font(.title3)
        .foregroundStyle(.secondary)
      if let errorMessage = session.errorMessage {
        Text(errorMessage)
          .font(.callout)
          .foregroundStyle(.red)
      }
    }
  }

  private var languagePanel: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(strings.languageLabel)
        .font(.headline)
      Picker(strings.languageLabel, selection: $selectedLanguageValue) {
        ForEach(AppLanguage.allCases) { language in
          Text(language.displayName).tag(language.rawValue)
        }
      }
      .labelsHidden()
      .pickerStyle(.segmented)
      .frame(maxWidth: 320)
    }
  }

  private var transportPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(strings.connection)
        .font(.headline)
      TextField(strings.port, text: $session.listenPort)
        .frame(width: 120)
      HStack {
        Button {
          session.startListening()
        } label: {
          Label(strings.listen, systemImage: "antenna.radiowaves.left.and.right")
        }
        .buttonStyle(.borderedProminent)

        Button {
          session.stopListening()
        } label: {
          Label(strings.stop, systemImage: "stop.fill")
        }
        .buttonStyle(.bordered)

        Button {
          session.toggleSelfTest()
        } label: {
          Label(session.isRunningSelfTest ? strings.stopTest : strings.selfTest, systemImage: session.isRunningSelfTest ? "waveform.slash" : "waveform")
        }
        .buttonStyle(.bordered)
      }
      Text(strings.packets(received: session.receivedPacketCount, dropped: session.droppedPacketCount))
        .font(.callout)
        .foregroundStyle(.secondary)
      Text(strings.buffer(packetCount: session.bufferedPacketCount))
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }

  private var diagnosticsPanel: some View {
    let diagnostics = session.diagnostics
    let localizedDiagnostics = strings.diagnostics(diagnostics)
    return VStack(alignment: .leading, spacing: 8) {
      Text(strings.diagnostics)
        .font(.headline)
      Text(localizedDiagnostics.message)
        .font(.subheadline.weight(.semibold))
      if let latency = diagnostics.latencyMilliseconds {
        Text(strings.latency(milliseconds: latency))
          .font(.callout)
          .foregroundStyle(.secondary)
      }
      Text(localizedDiagnostics.recommendation)
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }

  private var voicePanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(strings.voiceMix)
        .font(.headline)
      Slider(value: $session.settings.inputGain, in: 0...2) {
        Text(strings.voiceGain)
      } minimumValueLabel: {
        Text("0")
      } maximumValueLabel: {
        Text("2x")
      }
      Slider(value: Binding(
        get: { Double(session.settings.targetLatencyMilliseconds) },
        set: { session.settings.targetLatencyMilliseconds = Int($0) }
      ), in: 20...150, step: 1) {
        Text(strings.targetLatency)
      } minimumValueLabel: {
        Text("20 ms")
      } maximumValueLabel: {
        Text("150 ms")
      }
      ProgressView(value: session.levelMeter.average)
    }
  }

  private var accompanimentPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(strings.accompaniment)
        .font(.headline)
      HStack {
        Button {
          session.isImportingAccompaniment = true
        } label: {
          Label(strings.chooseLocalTrack, systemImage: "folder")
        }
        .buttonStyle(.bordered)

        Button {
          session.toggleAccompanimentPlayback()
        } label: {
          Label(session.accompanimentState.isPlaying ? strings.pause : strings.play, systemImage: session.accompanimentState.isPlaying ? "pause.fill" : "play.fill")
        }
        .buttonStyle(.borderedProminent)
        .disabled(session.accompanimentState.fileName == nil)

        Button {
          session.stopAccompaniment()
        } label: {
          Label(strings.stop, systemImage: "stop.fill")
        }
        .buttonStyle(.bordered)
        .disabled(session.accompanimentState.fileName == nil)

        Button {
        } label: {
          Label(strings.appleMusic, systemImage: "music.note.list")
        }
        .buttonStyle(.bordered)
      }
      if let fileName = session.accompanimentState.fileName {
        Text(fileName)
          .font(.callout)
          .foregroundStyle(.secondary)
        Slider(value: Binding(
          get: { session.accompanimentState.progress },
          set: { session.seekAccompaniment(to: $0) }
        ), in: 0...1) {
          Text(strings.trackProgress)
        } minimumValueLabel: {
          Text(session.accompanimentState.elapsedText)
        } maximumValueLabel: {
          Text(session.accompanimentState.durationText)
        }
        Slider(value: Binding(
          get: { session.accompanimentState.volume },
          set: { session.setAccompanimentVolume($0) }
        ), in: 0...1) {
          Text(strings.accompanimentVolume)
        } minimumValueLabel: {
          Text("0")
        } maximumValueLabel: {
          Text("1")
        }
      }
      Text(strings.localAccompanimentNotice)
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }

  private var lyricsPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(strings.lyrics)
        .font(.headline)
      HStack {
        Button {
          session.isImportingLyrics = true
        } label: {
          Label(strings.importLRC, systemImage: "text.quote")
        }
        .buttonStyle(.bordered)

        if let lyricsFileName = session.lyricsFileName {
          Text(lyricsFileName)
            .font(.callout)
            .foregroundStyle(.secondary)
        }
      }

      if let activeLine = session.activeLyricsLine {
        Text(activeLine.text)
          .font(.title2.weight(.semibold))
      } else {
        Text(strings.importLyricsHint)
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      if let nextLine = session.nextLyricsLine {
        Text(nextLine.text)
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      Slider(value: Binding(
        get: { session.lyricsOffsetSeconds },
        set: { session.setLyricsOffset($0) }
      ), in: -3...3, step: 0.1) {
        Text(strings.lyricsOffset)
      } minimumValueLabel: {
        Text("-3s")
      } maximumValueLabel: {
        Text("+3s")
      }
      Text(strings.offset(seconds: session.lyricsOffsetSeconds))
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  private var appleMusicPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(strings.appleMusic)
        .font(.headline)

      HStack {
        Text(strings.status(session.appleMusicAuthorization.statusDescription))
          .font(.callout)
          .foregroundStyle(.secondary)
        Button {
          session.requestAppleMusicAuthorization()
        } label: {
          Label(strings.authorize, systemImage: "person.badge.key")
        }
        .buttonStyle(.bordered)
      }

      HStack {
        TextField(strings.searchAppleMusic, text: $session.appleMusicQuery)
        Button {
          session.searchAppleMusic()
        } label: {
          Label(session.isSearchingAppleMusic ? strings.searching : strings.search, systemImage: "magnifyingglass")
        }
        .buttonStyle(.borderedProminent)
        .disabled(session.appleMusicQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }

      if !session.appleMusicResults.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
          ForEach(session.appleMusicResults) { track in
            HStack {
              VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                  .font(.subheadline.weight(.semibold))
                Text([track.artistName, track.albumTitle].compactMap { $0 }.joined(separator: " - "))
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              Button {
                session.playAppleMusic(track: track)
              } label: {
                Label(session.playingAppleMusicTrackID == track.id ? strings.playing : strings.play, systemImage: session.playingAppleMusicTrackID == track.id ? "speaker.wave.2.fill" : "play.fill")
              }
              .buttonStyle(.bordered)
              .disabled(!session.appleMusicAuthorization.canSearchCatalog)
            }
          }
        }
      }

      Text(strings.appleMusicSafetyNotice)
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }
}

struct MacRootViewPreviews: PreviewProvider {
  static var previews: some View {
    MacRootView(session: MacReceiverSession())
  }
}
