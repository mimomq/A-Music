# Release Notes

## 0.1.0

- Added initial Swift Package structure for shared core, iPhone app, and Mac app.
- Added product backlog and architecture documentation.
- Added shared audio settings, session state, and audio packet framing.
- Added placeholder SwiftUI flows for microphone sending and Mac receiving.
- Added unit tests for shared packet and settings behavior.

## 0.2.0

- Added mono Float32 PCM microphone capture service with `AVAudioEngine`.
- Added TCP audio sender and receiver services with `Network.framework`.
- Added length-prefixed stream packet encoder/decoder for TCP transport.
- Added Mac `AVAudioEngine` playback service.
- Wired the phone and Mac session models to real capture, send, receive, and playback services.
- Added manual Mac host entry on the phone and listen-port entry on the Mac.
- Added tests for stream decoding and Float32 level metering.

## 0.3.0

- Added Bonjour receiver discovery on the phone.
- Added discovered Mac receiver selection UI while keeping manual host entry as a fallback.
- Added shared discovered receiver model.
- Added shared audio jitter buffer and tests.
- Wired Mac playback through the jitter buffer and surfaced buffer depth in the receiver UI.
- Confirmed SwiftPM build and 10 core tests pass.

## 0.4.0

- Added shared connection diagnostics model with health, latency, drop, buffer, and recommendation output.
- Added Mac diagnostics panel.
- Added local accompaniment player service using `AVAudioPlayer`.
- Added Mac file importer for user-owned local audio files.
- Added accompaniment play, pause, stop, and volume controls.
- Added connection diagnostics tests.
- Confirmed SwiftPM build and 13 core tests pass.

## 0.5.0

- Added local accompaniment elapsed time, duration, progress, and seeking.
- Added shared track time formatter and tests.
- Added Apple Music catalog track model.
- Added MusicKit authorization service on Mac.
- Added Apple Music catalog search panel on Mac.
- Preserved Apple Music compliance boundary: catalog metadata only, no protected audio extraction or transformation.
- Confirmed SwiftPM build and 15 core tests pass.

## 0.6.0

- Added shared LRC lyrics parser.
- Added tests for timed lyrics, multiple timestamps per line, and active lyric lookup.
- Added Mac LRC import with synced current and next lyric display.
- Added Apple Music playback handoff for catalog search results through `ApplicationMusicPlayer`.
- Kept Apple Music compliance boundary: playback handoff only, no protected audio extraction or transformation.
- Confirmed SwiftPM build and 18 core tests pass.

## 0.7.0

- Added shared karaoke session snapshot model.
- Added shared lyrics timeline helper for offset-aware active and next-line lookup.
- Added Mac session persistence for local accompaniment path, lyrics path, volume, and lyrics offset.
- Added lyrics offset slider for manual sync correction.
- Added tests for session snapshot coding and lyrics offset lookup.
- Confirmed SwiftPM build and 21 core tests pass.

## 0.8.0

- Added shared test tone generator for audio-chain verification.
- Added Mac receiver self-test that injects generated audio packets through the existing receive, jitter buffer, playback, diagnostics, and UI counter path.
- Added MVP verification guide with Mac-only and iPhone-to-Mac checklists.
- Added tests for test tone payload and packet generation.
- Confirmed SwiftPM build and 23 core tests pass.
