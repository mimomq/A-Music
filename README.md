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

Version `0.2.0` adds the first real audio-path implementation:

- Phone side captures microphone samples as mono Float32 PCM.
- Phone side sends length-prefixed audio packets over TCP.
- Mac side listens on port `49555`, decodes packets, tracks drops, and schedules PCM playback.
- The iPhone UI includes a Mac host field for manual local-network connection.

Bonjour discovery, echo cancellation, latency calibration, and signed app bundle targets remain upcoming product slices.

Version `0.3.0` improves the local-network product loop:

- Mac receiver advertises a Bonjour `_singbridge._tcp` service.
- Phone app can scan nearby receivers and select one instead of requiring manual host entry.
- Mac playback uses a small packet jitter buffer before scheduling audio.
- Core tests cover jitter buffering, stream decoding, packet framing, audio settings, packet loss, and level metering.

Version `0.4.0` adds usability features for a more complete karaoke loop:

- Mac receiver shows connection diagnostics with latency, packet drops, buffer depth, and suggested fixes.
- Mac receiver can choose and play a local accompaniment audio file.
- Local accompaniment supports play, pause, stop, and volume controls.
- Core tests cover connection diagnostics in addition to transport and audio primitives.

Version `0.5.0` starts the music-library experience:

- Local accompaniment adds elapsed/duration display and seeking.
- Apple Music adds MusicKit authorization and catalog search.
- Apple Music results show track, artist, and album metadata.
- Apple Music remains metadata/search only; protected audio is not extracted, transformed, recorded, or exported.

Version `0.6.0` adds singing context:

- Local `.lrc` lyric files can be imported on Mac.
- Lyrics sync to local accompaniment time with current and next-line display.
- Apple Music catalog results can be handed off to `ApplicationMusicPlayer` for compliant system playback.
- LRC parsing supports multiple timestamps per line and is covered by tests.

Version `0.7.0` makes local sessions easier to resume:

- Mac saves the last local accompaniment path, lyrics path, accompaniment volume, and lyrics offset.
- Mac restores available local accompaniment and lyrics on launch.
- Lyrics offset can be adjusted from -3s to +3s for manual sync correction.
- Core tests cover session snapshot encoding and lyrics offset lookup.

## Development

Open the package in Xcode:

```sh
open Package.swift
```

Run tests when Xcode command line tools are available:

```sh
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
swift test --disable-sandbox --build-path /private/tmp/singbridge-build
```

The explicit build path avoids macOS Desktop/File Provider metadata on test bundles.

## Manual Smoke Test

1. Start the Mac receiver and press `Listen`.
2. Press `Scan` on the phone app.
3. Select the discovered Mac receiver, or enter the Mac IP address manually if discovery is blocked.
4. Press `Start` on the phone app.
5. Confirm the Mac packet counter and buffer count update, and voice level meters move.
6. Choose a local audio track on the Mac and confirm accompaniment controls work.
7. Search Apple Music from the Mac panel after authorization and confirm catalog results appear.
8. Import an `.lrc` file and confirm current lyrics advance with the local accompaniment timeline.
9. Adjust lyrics offset and confirm the active lyric changes earlier or later.

For the full verification sequence, see `Docs/MVP_VERIFICATION.md`.
