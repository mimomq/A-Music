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

## v0.3 Pairing and Buffer Checks

- Mac receiver appears in phone scan results on the same Wi-Fi network.
- Selecting a discovered Mac updates the selected receiver state.
- Phone can still connect with manual host entry if discovery is unavailable.
- Mac buffer count rises before playback starts and then stays near the target depth.
- Re-starting listen or capture clears packet, drop, meter, and buffer state.

## v0.4 Diagnostics and Accompaniment Checks

- Diagnostics show idle, waiting, healthy, watch, and poor states from current connection data.
- High latency or many dropped packets produce a warning recommendation.
- Mac can choose a local audio file with the system file importer.
- Local accompaniment can play, pause, stop, and change volume.
- Apple Music remains clearly marked as a compliant future integration, not raw audio extraction.

## v0.5 Library and Progress Checks

- Local accompaniment shows elapsed and duration text.
- Dragging the accompaniment progress slider seeks within the local track.
- MusicKit authorization status appears in the Apple Music panel.
- Apple Music catalog search returns title, artist, and album metadata for authorized users.
- Apple Music results do not offer recording, exporting, raw waveform access, or vocal removal.

## v0.6 Lyrics and Playback Handoff Checks

- LRC import accepts plain text `.lrc` files.
- Current lyric follows local accompaniment `currentTime`.
- Next lyric preview advances as the track progresses.
- Apple Music result play button hands playback to `ApplicationMusicPlayer`.
- Apple Music playback still does not expose raw audio, recording, vocal removal, or waveform editing.

## v0.7 Persistence and Sync Checks

- Mac saves the selected local accompaniment path.
- Mac saves the selected LRC lyrics path.
- Mac saves accompaniment volume and lyrics offset.
- Relaunching the Mac app restores files that still exist on disk.
- Lyrics offset slider changes active and next lyric selection.

## v0.8 MVP Verification Checks

- Mac `Self Test` emits a short audible tone.
- Self test increments packet count and updates buffer count.
- Self test moves the voice level meter.
- Self test updates diagnostics without requiring iPhone or network setup.
- `Docs/MVP_VERIFICATION.md` covers automated tests, Mac self-test, iPhone microphone streaming, accompaniment, lyrics, and Apple Music checks.

## v0.3 Karaoke Checks

- Local accompaniment can be selected and played.
- Voice gain does not clip at normal singing volume.
- Mute immediately suppresses outbound voice payloads.
- User-facing errors appear for denied microphone, denied local network, and unavailable output device.
