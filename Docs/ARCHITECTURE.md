# Architecture

## System Overview

SingBridge is split into three layers:

1. Phone capture app: owns microphone permission, capture state, local controls, and outbound audio streaming.
2. Mac receiver app: owns pairing, incoming packet buffering, speaker playback, voice mix controls, and accompaniment controls.
3. Shared core: owns serializable session state, audio settings, packet framing, and validation rules.

## Transport

The intended production transport is `Network.framework` over a local Wi-Fi network. Bluetooth is treated as a fallback discovery or future transport because it is more likely to introduce unacceptable karaoke monitoring latency.

The current implementation uses a TCP connection to port `49555` with manual host entry. Bonjour service metadata is declared by the listener, but automatic discovery and pairing UI are not complete yet.

The first packet format is deliberately simple:

- 4-byte magic header: `SBRG`
- 1-byte protocol version
- 8-byte sequence number
- 8-byte sender timestamp in nanoseconds
- encoded audio payload

This supports ordering, dropped-frame detection, and latency measurement before the project commits to a final codec.

TCP stream framing adds a 4-byte big-endian packet length prefix before each encoded packet.

## Audio

The MVP uses uncompressed PCM internally while the product proves latency. Later versions can evaluate Opus or AAC-LC when network bandwidth, quality, or battery pressure requires compression.

`v0.2.0` captures mono Float32 PCM and schedules it directly into an `AVAudioPlayerNode` on the Mac. Mac playback should use a small jitter buffer next. Too little buffering causes glitches; too much buffering makes singing feel disconnected.

## Apple Music

MusicKit can support catalog search, library browsing, and playback features where user authorization and subscription status permit it. Apple Music tracks are not treated as raw editable files. Features such as vocal removal, pitch shifting, waveform extraction, exporting, or recording mixed Apple Music output require separate rights or user-owned audio.

## Privacy

- Microphone capture starts only after explicit user action.
- Audio streams stay on the local network for the MVP.
- The app should show persistent capture/connection status.
- Recording is out of scope until rights and storage behavior are defined.
