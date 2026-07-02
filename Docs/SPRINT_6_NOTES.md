# Sprint 6 Notes

## Completed in v0.6.0

- Added LRC lyric parsing in shared core logic.
- Added Mac lyric import for local accompaniment.
- Added current and next lyric display synced to local track time.
- Added compliant Apple Music playback handoff for catalog search results.

## Known Product Gaps

- Apple Music user library browsing is not implemented yet.
- Lyrics are currently imported manually and not persisted across launches.
- Lyrics sync only follows local accompaniment playback, not Apple Music playback state.
- Recording and scoring remain out of scope until rights and latency handling are stronger.

## Next Sprint

- Add MusicKit user library browsing.
- Persist local accompaniment and lyrics metadata.
- Add local lyric offset adjustment.
- Add round-trip latency messages between phone and Mac.
