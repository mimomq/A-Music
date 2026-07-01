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
