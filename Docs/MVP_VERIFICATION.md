# MVP Verification

Use this checklist to verify the current SingBridge MVP one development task at a time. Start with Mac-only checks, then verify the iPhone app only after the Mac receiver is working.

For the detailed task split, see `Docs/DEVELOPMENT_TASKS.md`.

## 1. Automated Build and Unit Tests

```sh
cd /Users/li/Desktop/music
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
swift test --disable-sandbox --build-path /private/tmp/singbridge-build
```

Expected result: all tests pass.

## 2. Mac Audio Chain Self Test

1. Open `Package.swift` in Xcode.
2. Select `SingBridgeMac` and destination `My Mac`.
3. Run the Mac app only.
4. If Xcode reports a signing issue, run the Mac app from Terminal:

```sh
cd /Users/li/Desktop/music
DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer \
swift run SingBridgeMac
```

5. Press `Self Test`.
6. Confirm a short tone is heard from the Mac speaker.
7. Confirm packet count, buffer count, level meter, and diagnostics update.

Why this matters: it verifies the Mac playback path, packet handling, jitter buffer, diagnostics, and UI counters before involving the phone or network.

## 3. iPhone Microphone Sender

1. Keep `SingBridgeMac` running on Mac and press `Listen`.
2. In Xcode, switch to `SingBridgePhone` and destination `Li's iPhone` or the physical iPhone name shown in the toolbar.
3. Do not run `SingBridgeMac` with the iPhone destination selected.
4. Run the phone app.
5. Press `Scan` on iPhone.
6. Select the discovered Mac receiver.
7. Press `Start` on iPhone.
8. Speak into the iPhone microphone.
9. Confirm Mac packet count, buffer count, and voice level move.
10. Confirm voice plays from the Mac speaker.

Fallback: if discovery fails, enter the Mac IP address manually in the phone app.

## 4. Integration: iPhone Microphone to Mac

1. Run `SingBridgeMac` and press `Listen`.
2. Run `SingBridgePhone` on iPhone.
3. Press `Scan` on iPhone.
4. Select the discovered Mac receiver.
5. Press `Start` on iPhone.
6. Speak into the iPhone microphone.
7. Confirm Mac packet count, buffer count, and voice level move.
8. Confirm voice plays from the Mac speaker.

Fallback: if discovery fails, enter the Mac IP address manually in the phone app.

## 5. Local Accompaniment

1. On Mac, choose a local user-owned audio file.
2. Press `Play`, `Pause`, and `Stop`.
3. Drag the progress slider.
4. Adjust accompaniment volume.
5. Relaunch the Mac app and confirm the file is restored when it still exists on disk.

## 6. Lyrics

1. Import a plain-text `.lrc` file.
2. Play local accompaniment.
3. Confirm current and next lyric lines update with playback.
4. Adjust lyrics offset from `-3s` to `+3s`.
5. Relaunch the Mac app and confirm lyrics and offset are restored when the file still exists on disk.

## 7. Apple Music

1. Press `Authorize` in the Apple Music panel.
2. Search for a song.
3. Confirm track, artist, and album metadata appear.
4. Press `Play` on a result.

Expected behavior: playback is handed to `ApplicationMusicPlayer`. SingBridge does not extract, transform, record, export, or vocal-remove protected Apple Music audio.

## Known MVP Limits

- Echo cancellation and feedback suppression are not implemented.
- Real-device app signing and App Store packaging still need dedicated Xcode app targets.
- Apple Music user library browsing is not implemented.
- Recording and scoring are not implemented.
- File persistence uses paths; sandboxed distribution should move to security-scoped bookmarks.
