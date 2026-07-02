# SingBridge Phone App

Open `SingBridgePhoneApp.xcodeproj` in Xcode when working only on the iPhone microphone sender.

Use this target and destination:

- Scheme: `SingBridgePhoneApp`
- App target/product: `SingBridgePhone`
- Destination: your physical iPhone

This project intentionally excludes the Mac executable target.

The source folders are linked back to the main repository so edits stay in one codebase.

If Xcode asks for signing, select the `SingBridgePhone` app target, open `Signing & Capabilities`, choose your personal team, and let Xcode manage signing automatically.
