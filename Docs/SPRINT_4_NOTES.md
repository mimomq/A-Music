# Sprint 4 Notes

## Completed in v0.4.0

- Added connection diagnostics that translate latency, packet drop, and buffer state into user-facing health messages.
- Added a Mac diagnostics panel so the receiver is easier to troubleshoot during karaoke sessions.
- Added local accompaniment file selection on Mac using SwiftUI `fileImporter`.
- Added local accompaniment playback controls for play, pause, stop, and volume.

## Known Product Gaps

- Diagnostics still use one-way packet timestamps, not a synchronized round-trip latency protocol.
- Local accompaniment playback does not yet show duration, progress, seeking, or lyrics.
- Security-scoped bookmarks are not persisted for selected accompaniment files.
- The Apple Music button remains a placeholder until MusicKit authorization and compliant playback are implemented.

## Next Sprint

- Add accompaniment progress, seeking, and track metadata.
- Add MusicKit authorization and catalog search.
- Add round-trip latency ping messages between phone and Mac.
- Create signed app bundle project files for real device QA.
