import SingBridgeCore
import SwiftUI

@main
struct SingBridgePhoneApp: App {
  @StateObject private var microphoneSession = PhoneMicrophoneSession()

  var body: some Scene {
    WindowGroup {
      PhoneRootView(session: microphoneSession)
    }
  }
}
