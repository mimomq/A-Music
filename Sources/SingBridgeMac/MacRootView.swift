import SingBridgeCore
import SwiftUI

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
          voicePanel
          accompanimentPanel
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
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
      }
      Text("Packets: \(session.receivedPacketCount) received, \(session.droppedPacketCount) dropped")
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
        } label: {
          Label("Choose Local Track", systemImage: "folder")
        }
        .buttonStyle(.bordered)

        Button {
        } label: {
          Label("Apple Music", systemImage: "music.note.list")
        }
        .buttonStyle(.bordered)
      }
      Text("Apple Music support will use MusicKit-authorized catalog and playback features only.")
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
