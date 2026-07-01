import SingBridgeCore
import SwiftUI

@main
struct SingBridgeMacApp: App {
  @StateObject private var receiverSession = MacReceiverSession()

  var body: some Scene {
    WindowGroup {
      MacRootView(session: receiverSession)
        .frame(minWidth: 720, minHeight: 460)
    }
  }
}
