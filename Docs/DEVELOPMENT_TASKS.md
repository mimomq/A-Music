# Development Task Split

SingBridge now treats the Mac app and iPhone app as separate development tasks. Do not build or validate both targets as one combined task. Each task has its own run target, acceptance checks, and failure surface.

## Task A: Mac Receiver

Goal: make the Mac app run independently as the karaoke receiver and control desk.

Scope:

- Launch `SingBridgeMac` on `My Mac`.
- Listen on the local receiver port.
- Play incoming Float32 PCM packets through Mac speakers.
- Run the built-in audio-chain self test without an iPhone.
- Show connection diagnostics, packet counts, buffer depth, and voice level.
- Load local accompaniment, control playback, volume, progress, and lyrics sync.
- Use MusicKit only for authorized catalog/search/playback handoff.

Out of scope:

- iPhone microphone capture.
- iPhone discovery UI.
- Device signing for iPhone.
- End-to-end phone-to-Mac streaming validation.

Mac acceptance checks:

1. `SingBridgeMac` launches on `My Mac`.
2. Pressing `Self Test` produces an audible test tone.
3. Packet count, buffer count, level meter, and diagnostics update during self test.
4. `Listen` starts the receiver without crashing.
5. Local accompaniment can be selected, played, paused, stopped, and seeked.
6. Lyrics import and offset controls work with local accompaniment.

Recommended command-line run when Xcode signing gets in the way:

```sh
cd /Users/li/Desktop/music
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
swift run SingBridgeMac
```

## Task B: iPhone Microphone

Goal: make the iPhone app run as a microphone sender that can connect to an already-running Mac receiver.

Scope:

- Launch `SingBridgePhone` on a physical iPhone.
- Request microphone permission only when capture starts.
- Discover nearby Mac receivers with Bonjour.
- Allow manual Mac host fallback.
- Capture mono Float32 microphone audio.
- Apply mute and input gain before sending packets.
- Stream audio packets to the selected Mac receiver.

Out of scope:

- Mac receiver playback implementation.
- Local accompaniment and lyrics controls.
- Apple Music playback.
- Mac self test.

iPhone acceptance checks:

1. `SingBridgeMac` is already running and listening.
2. `SingBridgePhone` launches on iPhone with a valid signing team.
3. Pressing `Scan` finds the Mac receiver on the same Wi-Fi network.
4. Manual host entry still works if discovery fails.
5. Pressing `Start` asks for microphone permission when needed.
6. Speaking into the iPhone moves the phone level meter.
7. The Mac packet count and voice level update after connection.

## Integration Gate

Run integration only after Task A and Task B pass independently.

Integration checks:

1. Start `SingBridgeMac` on Mac and press `Listen`.
2. Start `SingBridgePhone` on iPhone.
3. Connect by scan result or manual host.
4. Press `Start` on iPhone.
5. Confirm voice reaches the Mac speaker.
6. Confirm accompaniment can play at the same time.

## Current Build Rule

Build one target at a time:

- For Mac work: scheme/product `SingBridgeMac`, destination `My Mac`.
- For iPhone work: scheme/product `SingBridgePhone`, destination the physical iPhone.

Do not use an iPhone destination while running `SingBridgeMac`, and do not use `My Mac` while validating iPhone capture.

## Local Xcode Folders

Open these folders directly in Xcode:

- Mac receiver: `/Users/li/Desktop/music/SingBridgeMacApp`
- iPhone microphone: `/Users/li/Desktop/music/SingBridgePhoneApp`

Each folder is its own Swift Package and contains only the matching executable target. The source folders inside these packages are linked back to the main repository, so edits made from either Xcode window still update the shared codebase.
