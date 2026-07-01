# Sprint 2 Notes

## Completed in v0.2.0

- The phone session can start microphone capture and stream packets to a configured Mac host.
- The Mac session can listen for TCP connections, decode audio packets, track packet drops, and schedule playback.
- Packet framing is now stream-safe with a 4-byte length prefix.
- Level metering is calculated from Float32 PCM payloads in shared core logic.

## Known Product Gaps

- Pairing still requires manually entering the Mac IP address.
- Latency shown on the Mac uses sender packet timestamps and is only a rough development signal until clock synchronization or round-trip measurement is added.
- Playback has no adaptive jitter buffer yet.
- Echo cancellation and feedback suppression are not implemented.
- The Swift Package is still a development scaffold, not signed App Store app bundles.

## Next Sprint

- Add Bonjour discovery and one-tap pairing.
- Add a small jitter buffer before Mac playback.
- Add manual latency calibration and a simple latency test tone.
- Add user-facing setup guidance for same-network permission failures.
