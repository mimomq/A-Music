# Sprint 7 Notes

## Completed in v0.7.0

- Added persisted local karaoke session metadata for Mac.
- Restored local accompaniment and lyrics files when paths still exist.
- Added manual lyrics offset adjustment for simple synchronization correction.
- Added core tests for persistence snapshot coding and offset-aware lyric lookup.

## Known Product Gaps

- File access is stored as plain paths; sandboxed app bundles will need security-scoped bookmarks.
- Lyrics offset is global to the current session, not per lyric file.
- Apple Music library browsing is still pending.
- Round-trip network latency measurement is still pending.

## Next Sprint

- Add MusicKit user library browsing.
- Add round-trip ping messages between phone and Mac.
- Add signed app bundle project files for real-device QA.
- Upgrade file persistence to security-scoped bookmarks when app sandboxing is enabled.
