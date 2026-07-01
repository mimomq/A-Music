# QA Checklist

## v0.1 Static Checks

- Package opens in Xcode 15+.
- `SingBridgeCoreTests` pass.
- iPhone app launches and shows microphone start, mute, and gain controls.
- Mac app launches and shows receiver, voice, and accompaniment panels.
- Privacy strings exist for microphone, local network, and Apple Music usage.

## v0.2 Audio Path Checks

- iPhone prompts for microphone permission only when capture starts.
- Mac listens on port `49555`.
- Phone can connect to a manually entered Mac host on the same Wi-Fi network.
- Audio plays through Mac speakers with no crash after five minutes.
- Median mouth-to-speaker latency is measured and recorded.
- Dropped packets are counted during poor network conditions.
- Stopping either app closes the session cleanly.

## v0.3 Karaoke Checks

- Local accompaniment can be selected and played.
- Voice gain does not clip at normal singing volume.
- Mute immediately suppresses outbound voice payloads.
- User-facing errors appear for denied microphone, denied local network, and unavailable output device.
