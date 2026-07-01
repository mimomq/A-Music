# Sprint 3 Notes

## Completed in v0.3.0

- Mac receiver advertises `_singbridge._tcp` through `NWListener.Service`.
- Phone app browses for nearby SingBridge Mac receivers with `NWBrowser`.
- Phone app can select a discovered receiver and connect using the resolved Bonjour endpoint.
- Manual host entry remains as a fallback.
- Mac playback now runs through a small packet jitter buffer with visible buffer depth.

## Known Product Gaps

- Discovery still needs hands-on QA across real iPhone and Mac devices because Simulator/local SwiftPM tests cannot prove local-network permission prompts or firewall behavior.
- Jitter buffering is fixed-depth, not adaptive.
- Latency reporting is still a rough development estimate.
- There is no echo cancellation or feedback suppression.

## Next Sprint

- Add latency calibration and round-trip ping measurement.
- Add user-facing diagnostics for local-network permission and firewall failures.
- Add a local accompaniment file picker on Mac.
- Start separating development Swift Package targets from signed app bundle projects.
