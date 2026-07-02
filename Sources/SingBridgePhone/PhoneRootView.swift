import SingBridgeCore
import SwiftUI

struct PhoneRootView: View {
  @ObservedObject var session: PhoneMicrophoneSession
  @AppStorage(AppLanguage.storageKey) private var selectedLanguageValue = AppLanguage.english.rawValue

  private var language: AppLanguage {
    AppLanguage.fromStorageValue(selectedLanguageValue)
  }

  private var strings: AppStrings {
    AppStrings(language: language)
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        connectionPanel
        discoveryPanel
        levelPanel
        controls
        settingsPanel
        Spacer(minLength: 0)
      }
      .padding()
      .navigationTitle(strings.singBridgeMic)
    }
  }

  private var connectionPanel: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(strings.connectionState(session.connectionState))
        .font(.headline)
      Text(session.isCapturing ? strings.microphoneReadyHint : strings.startHint)
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
      Text(strings.voiceLevel)
        .font(.subheadline.weight(.semibold))
      ProgressView(value: session.levelMeter.average)
      ProgressView(value: session.levelMeter.peak)
        .tint(.orange)
    }
  }

  private var discoveryPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text(strings.nearbyMacs)
          .font(.headline)
        Spacer()
        Button {
          session.isDiscovering ? session.stopDiscovery() : session.startDiscovery()
        } label: {
          Label(session.isDiscovering ? strings.stopScan : strings.scan, systemImage: session.isDiscovering ? "pause.fill" : "magnifyingglass")
        }
        .buttonStyle(.bordered)
      }

      if session.discoveredReceivers.isEmpty {
        Text(strings.noReceiverHint)
          .font(.callout)
          .foregroundStyle(.secondary)
      } else {
        ForEach(session.discoveredReceivers) { receiver in
          Button {
            session.select(receiver: receiver)
          } label: {
            HStack {
              VStack(alignment: .leading, spacing: 2) {
                Text(receiver.name)
                  .font(.subheadline.weight(.semibold))
                Text(receiver.endpointText)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              Spacer()
              if receiver.id == session.selectedReceiverID {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundStyle(.green)
              }
            }
          }
          .buttonStyle(.bordered)
        }
      }
    }
  }

  private var controls: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextField(strings.macHost, text: $session.macHost)
        #if os(iOS)
        .keyboardType(.numbersAndPunctuation)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        #endif

      HStack(spacing: 12) {
        Button {
          session.isCapturing ? session.stop() : session.start()
        } label: {
          Label(session.isCapturing ? strings.stop : strings.start, systemImage: session.isCapturing ? "stop.fill" : "mic.fill")
        }
        .buttonStyle(.borderedProminent)

        Button {
          session.toggleMute()
        } label: {
          Label(session.settings.isMuted ? strings.unmute : strings.mute, systemImage: session.settings.isMuted ? "mic.slash.fill" : "mic.fill")
        }
        .buttonStyle(.bordered)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var settingsPanel: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(strings.languageLabel)
        .font(.headline)
      Picker(strings.languageLabel, selection: $selectedLanguageValue) {
        ForEach(AppLanguage.allCases) { language in
          Text(language.displayName).tag(language.rawValue)
        }
      }
      .labelsHidden()
      .pickerStyle(.segmented)

      Text(strings.monitor)
        .font(.headline)
      Slider(value: $session.settings.inputGain, in: 0...2) {
        Text(strings.inputGain)
      } minimumValueLabel: {
        Text("0")
      } maximumValueLabel: {
        Text("2x")
      }
      Slider(value: $session.settings.monitorMix, in: 0...1) {
        Text(strings.mix)
      } minimumValueLabel: {
        Text(strings.dry)
      } maximumValueLabel: {
        Text(strings.wet)
      }
    }
  }
}

struct PhoneRootViewPreviews: PreviewProvider {
  static var previews: some View {
    PhoneRootView(session: PhoneMicrophoneSession())
  }
}
