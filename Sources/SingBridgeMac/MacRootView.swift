import SingBridgeCore
import SwiftUI
import UniformTypeIdentifiers

struct MacRootView: View {
  @ObservedObject var session: MacReceiverSession

  var body: some View {
    NavigationSplitView {
      List {
        Label("Receiver", systemImage: "dot.radiowaves.left.and.right")
        Label("Voice", systemImage: "waveform")
        Label("Music", systemImage: "music.note")
        Label("Settings", systemImage: "gearshape")
      }
      .navigationTitle("SingBridge")
    } detail: {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          header
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
      Text("Karaoke Receiver")
        .font(.largeTitle.weight(.bold))
      Text(session.connectionState.displayText)
        .font(.title3)
        .foregroundStyle(.secondary)
      if let errorMessage = session.errorMessage {
        Text(errorMessage)
          .font(.callout)
          .foregroundStyle(.red)
      }
    }
  }

  private var transportPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Connection")
        .font(.headline)
      TextField("Port", text: $session.listenPort)
        .frame(width: 120)
      HStack {
        Button {
          session.startListening()
        } label: {
          Label("Listen", systemImage: "antenna.radiowaves.left.and.right")
        }
        .buttonStyle(.borderedProminent)

        Button {
          session.stopListening()
        } label: {
          Label("Stop", systemImage: "stop.fill")
        }
        .buttonStyle(.bordered)

        Button {
          session.toggleSelfTest()
        } label: {
          Label(session.isRunningSelfTest ? "Stop Test" : "Self Test", systemImage: session.isRunningSelfTest ? "waveform.slash" : "waveform")
        }
        .buttonStyle(.bordered)
      }
      Text("Packets: \(session.receivedPacketCount) received, \(session.droppedPacketCount) dropped")
        .font(.callout)
        .foregroundStyle(.secondary)
      Text("Buffer: \(session.bufferedPacketCount) packets")
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }

  private var diagnosticsPanel: some View {
    let diagnostics = session.diagnostics
    return VStack(alignment: .leading, spacing: 8) {
      Text("Diagnostics")
        .font(.headline)
      Text(diagnostics.message)
        .font(.subheadline.weight(.semibold))
      if let latency = diagnostics.latencyMilliseconds {
        Text("Latency: \(latency) ms")
          .font(.callout)
          .foregroundStyle(.secondary)
      }
      Text(diagnostics.recommendation)
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }

  private var voicePanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Voice Mix")
        .font(.headline)
      Slider(value: $session.settings.inputGain, in: 0...2) {
        Text("Voice Gain")
      } minimumValueLabel: {
        Text("0")
      } maximumValueLabel: {
        Text("2x")
      }
      Slider(value: Binding(
        get: { Double(session.settings.targetLatencyMilliseconds) },
        set: { session.settings.targetLatencyMilliseconds = Int($0) }
      ), in: 20...150, step: 1) {
        Text("Target Latency")
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
      Text("Accompaniment")
        .font(.headline)
      HStack {
        Button {
          session.isImportingAccompaniment = true
        } label: {
          Label("Choose Local Track", systemImage: "folder")
        }
        .buttonStyle(.bordered)

        Button {
          session.toggleAccompanimentPlayback()
        } label: {
          Label(session.accompanimentState.isPlaying ? "Pause" : "Play", systemImage: session.accompanimentState.isPlaying ? "pause.fill" : "play.fill")
        }
        .buttonStyle(.borderedProminent)
        .disabled(session.accompanimentState.fileName == nil)

        Button {
          session.stopAccompaniment()
        } label: {
          Label("Stop", systemImage: "stop.fill")
        }
        .buttonStyle(.bordered)
        .disabled(session.accompanimentState.fileName == nil)

        Button {
        } label: {
          Label("Apple Music", systemImage: "music.note.list")
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
          Text("Track Progress")
        } minimumValueLabel: {
          Text(session.accompanimentState.elapsedText)
        } maximumValueLabel: {
          Text(session.accompanimentState.durationText)
        }
        Slider(value: Binding(
          get: { session.accompanimentState.volume },
          set: { session.setAccompanimentVolume($0) }
        ), in: 0...1) {
          Text("Accompaniment Volume")
        } minimumValueLabel: {
          Text("0")
        } maximumValueLabel: {
          Text("1")
        }
      }
      Text("Apple Music support will use MusicKit-authorized catalog and playback features only.")
        .font(.callout)
        .foregroundStyle(.secondary)
    }
  }

  private var lyricsPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Lyrics")
        .font(.headline)
      HStack {
        Button {
          session.isImportingLyrics = true
        } label: {
          Label("Import LRC", systemImage: "text.quote")
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
        Text("Import an LRC file to sync lyrics with local accompaniment.")
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
        Text("Lyrics Offset")
      } minimumValueLabel: {
        Text("-3s")
      } maximumValueLabel: {
        Text("+3s")
      }
      Text("Offset: \(session.lyricsOffsetSeconds, specifier: "%.1f")s")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
  }

  private var appleMusicPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Apple Music")
        .font(.headline)

      HStack {
        Text("Status: \(session.appleMusicAuthorization.statusDescription)")
          .font(.callout)
          .foregroundStyle(.secondary)
        Button {
          session.requestAppleMusicAuthorization()
        } label: {
          Label("Authorize", systemImage: "person.badge.key")
        }
        .buttonStyle(.bordered)
      }

      HStack {
        TextField("Search Apple Music", text: $session.appleMusicQuery)
        Button {
          session.searchAppleMusic()
        } label: {
          Label(session.isSearchingAppleMusic ? "Searching" : "Search", systemImage: "magnifyingglass")
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
                Label(session.playingAppleMusicTrackID == track.id ? "Playing" : "Play", systemImage: session.playingAppleMusicTrackID == track.id ? "speaker.wave.2.fill" : "play.fill")
              }
              .buttonStyle(.bordered)
              .disabled(!session.appleMusicAuthorization.canSearchCatalog)
            }
          }
        }
      }

      Text("Search uses MusicKit catalog metadata. Protected Apple Music audio is not extracted, transformed, recorded, or exported.")
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
