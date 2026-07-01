# Agile Plan

## Vision

Create a playful karaoke companion where the iPhone becomes the microphone, the Mac becomes the speaker and control desk, and users can sing along with legally available accompaniment.

## Personas

- Casual singer: wants quick setup, fun effects, and no hardware purchase.
- Party host: wants reliable pairing, loud output, and simple controls.
- Music hobbyist: wants lower latency, monitoring controls, and recording later.

## MVP Goal: v0.1

Prove the core loop: launch both apps, connect phone to Mac on the same network, capture mic input, send audio packets, play them on the Mac, and expose basic voice controls.

## Backlog

### Sprint 1: Foundations

- Create shared package structure for iOS/macOS apps.
- Define session state, audio settings, and packet framing.
- Build iPhone UI for connection and microphone controls.
- Build Mac UI for connection status, gain, latency, and accompaniment placeholder.
- Add unit tests for packet framing and settings validation.

### Sprint 2: Real Audio Path

- Implement iPhone `AVAudioEngine` capture. Done in `v0.2.0`.
- Encode PCM frames into stream packets. Done in `v0.2.0`.
- Implement local-network transport with `Network.framework`. Done in `v0.2.0` with manual host entry and improved in `v0.3.0` with Bonjour discovery.
- Add Mac receiver jitter buffer and `AVAudioEngine` playback. Playback is done in `v0.2.0`; basic packet jitter buffering is done in `v0.3.0`; adaptive jitter buffering remains open.
- Measure end-to-end latency on Wi-Fi.

### Sprint 3: Pairing and Stability

- Add Bonjour discovery and one-tap receiver selection. Done in `v0.3.0`.
- Add visible buffer depth and packet drop indicators. Done in `v0.3.0`.
- Add adaptive jitter buffer tuning.
- Add microphone permission recovery flow.
- Add setup diagnostics for local-network permission and firewall issues.

### Sprint 4: Karaoke Experience

- Add reverb, compression, noise gate, and input gain.
- Add local accompaniment file picker.
- Add lyrics/timing import for local tracks.
- Add recording for user-owned/local audio only.

### Sprint 5: Apple Music Surface

- Add MusicKit authorization.
- Add Apple Music catalog search and user library browsing.
- Add compliant playback handoff where allowed.
- Document feature limitations around DRM, raw audio access, vocal removal, and recording.

## Definition of Done

- The feature builds on both iOS and macOS targets.
- The happy path has manual QA notes or automated tests.
- User-facing errors exist for permission, network, and audio-device failures.
- No feature relies on extracting or modifying protected Apple Music audio.

## Risks

- Wireless latency may exceed comfortable live monitoring thresholds.
- Echo cancellation is difficult if the iPhone microphone hears the Mac speaker.
- Apple Music cannot be used as a raw accompaniment source for processing.
- App Store review will require clear privacy strings and compliant music usage.
