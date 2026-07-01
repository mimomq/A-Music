import XCTest
@testable import SingBridgeCore

final class ConnectionDiagnosticsTests: XCTestCase {
  func testIdleStateRecommendsStartingReceiver() {
    let diagnostics = ConnectionDiagnostics(
      state: .idle,
      droppedPacketCount: 0,
      bufferedPacketCount: 0
    )

    XCTAssertEqual(diagnostics.health, .idle)
    XCTAssertEqual(diagnostics.message, "Receiver is idle")
  }

  func testConnectedHealthyWhenLatencyAndDropsAreLow() {
    let diagnostics = ConnectionDiagnostics(
      state: .connected(deviceName: "Mac", latencyMilliseconds: 35),
      droppedPacketCount: 0,
      bufferedPacketCount: 3
    )

    XCTAssertEqual(diagnostics.health, .good)
    XCTAssertEqual(diagnostics.latencyMilliseconds, 35)
  }

  func testConnectedPoorWhenLatencyIsHigh() {
    let diagnostics = ConnectionDiagnostics(
      state: .connected(deviceName: "Mac", latencyMilliseconds: 140),
      droppedPacketCount: 0,
      bufferedPacketCount: 3
    )

    XCTAssertEqual(diagnostics.health, .poor)
  }
}
