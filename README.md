# SingBridge

SingBridge is an entertainment karaoke prototype that turns an iPhone into a wireless microphone for a Mac. The Mac receives low-latency vocal audio, plays it through the selected speaker, and provides the foundation for karaoke accompaniment, effects, scoring, and Apple Music catalog discovery.

## Product Direction

The first commercially realistic version focuses on a compliant and useful core:

- iPhone captures microphone audio.
- Mac discovers and connects to nearby iPhones on the local network.
- Mac receives and plays the voice stream with adjustable gain and monitoring delay.
- Music accompaniment starts with local, user-owned audio files.
- Apple Music integration is limited to catalog/search/playback surfaces that MusicKit allows. DRM-protected Apple Music audio is not treated as raw editable accompaniment.

## Repository Layout

- `Sources/SingBridgeCore`: shared models, audio settings, network session state, and packet framing.
- `Sources/SingBridgePhone`: iPhone SwiftUI app shell and microphone sender service.
- `Sources/SingBridgeMac`: macOS SwiftUI app shell and receiver/playback service.
- `Docs`: agile backlog, architecture notes, and release plan.

## MVP Status

Version `0.1.0` is a scaffolded Swift Package with the first product slices and testable shared logic. It is designed to be opened in Xcode 15+ and evolved into separate signed iOS/macOS app targets when bundle capabilities, entitlements, and App Store metadata are configured.

## Development

Open the package in Xcode:

```sh
open Package.swift
```

Run tests when Xcode command line tools are available:

```sh
swift test
```

The current machine reports missing command line developer tools, so local compilation could not be verified from the terminal yet.
