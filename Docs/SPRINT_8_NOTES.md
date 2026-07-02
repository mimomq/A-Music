# Sprint 8 Notes

## Completed in v0.8.0

- Added a shared test tone generator.
- Added a Mac receiver self-test button that drives the normal receive and playback pipeline.
- Added a practical MVP verification guide.

## Known Product Gaps

- The self-test verifies Mac audio-chain behavior, not iPhone microphone permissions or local-network discovery.
- Real-device app signing still needs dedicated app bundle project work.
- Round-trip latency messages are still pending.

## Next Sprint

- Add signed app bundle project files for real-device QA.
- Add round-trip ping messages between phone and Mac.
- Add local-network permission and firewall diagnostics.
