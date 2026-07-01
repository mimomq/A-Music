import SingBridgeCore
import SwiftUI

struct PhoneRootView: View {
  @ObservedObject var session: PhoneMicrophoneSession

  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        connectionPanel
        levelPanel
        controls
        settingsPanel
        Spacer(minLength: 0)
      }
      .padding()
      .navigationTitle("SingBridge Mic")
    }
  }

  private var connectionPanel: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(session.connectionState.displayText)
        .font(.headline)
      Text(session.isCapturing ? "Microphone is ready to stream to your Mac." : "Tap start when your Mac receiver is open.")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      if let errorMessage = session.errorMessage {
        Text(errorMessage)
          .font(.callout)
          .foregroundStyle(.red)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var levelPanel: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Voice Level")
        .font(.subheadline.weight(.semibold))
      ProgressView(value: session.levelMeter.average)
      ProgressView(value: session.levelMeter.peak)
        .tint(.orange)
    }
  }

  private var controls: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextField("Mac host", text: $session.macHost)
        #if os(iOS)
        .keyboardType(.numbersAndPunctuation)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        #endif

      HStack(spacing: 12) {
        Button {
          session.isCapturing ? session.stop() : session.start()
        } label: {
          Label(session.isCapturing ? "Stop" : "Start", systemImage: session.isCapturing ? "stop.fill" : "mic.fill")
        }
        .buttonStyle(.borderedProminent)

        Button {
          session.toggleMute()
        } label: {
          Label(session.settings.isMuted ? "Unmute" : "Mute", systemImage: session.settings.isMuted ? "mic.slash.fill" : "mic.fill")
        }
        .buttonStyle(.bordered)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var settingsPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Monitor")
        .font(.headline)
      Slider(value: $session.settings.inputGain, in: 0...2) {
        Text("Input Gain")
      } minimumValueLabel: {
        Text("0")
      } maximumValueLabel: {
        Text("2x")
      }
      Slider(value: $session.settings.monitorMix, in: 0...1) {
        Text("Mix")
      } minimumValueLabel: {
        Text("Dry")
      } maximumValueLabel: {
        Text("Wet")
      }
    }
  }
}

struct PhoneRootViewPreviews: PreviewProvider {
  static var previews: some View {
    PhoneRootView(session: PhoneMicrophoneSession())
  }
}
