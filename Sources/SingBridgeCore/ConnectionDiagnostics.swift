import Foundation

public struct ConnectionDiagnostics: Equatable, Sendable {
  public enum Health: String, Equatable, Sendable {
    case idle
    case good
    case watch
    case poor
  }

  public var health: Health
  public var latencyMilliseconds: Int?
  public var droppedPacketCount: Int
  public var bufferedPacketCount: Int
  public var message: String
  public var recommendation: String

  public init(
    state: ConnectionState,
    droppedPacketCount: Int,
    bufferedPacketCount: Int
  ) {
    self.latencyMilliseconds = state.latencyMilliseconds
    self.droppedPacketCount = droppedPacketCount
    self.bufferedPacketCount = bufferedPacketCount

    switch state {
    case .idle:
      health = .idle
      message = "Receiver is idle"
      recommendation = "Press Listen on the Mac, then connect from the phone."
    case .searching, .connecting:
      health = .watch
      message = "Waiting for connection"
      recommendation = "Keep both devices on the same Wi-Fi network and allow local network access."
    case .failed(let errorMessage):
      health = .poor
      message = "Connection failed"
      recommendation = errorMessage
    case .connected:
      if droppedPacketCount > 20 || (state.latencyMilliseconds ?? 0) > 120 {
        health = .poor
        message = "Connection needs attention"
        recommendation = "Move closer to Wi-Fi, stop other network-heavy apps, or lower speaker volume to avoid feedback."
      } else if droppedPacketCount > 0 || (state.latencyMilliseconds ?? 0) > 70 || bufferedPacketCount == 0 {
        health = .watch
        message = "Connection is usable"
        recommendation = "If singing feels delayed, reduce distance to the router or restart the session."
      } else {
        health = .good
        message = "Connection is healthy"
        recommendation = "Ready for karaoke."
      }
    }
  }
}

public extension ConnectionState {
  var latencyMilliseconds: Int? {
    if case .connected(_, let latencyMilliseconds) = self {
      return latencyMilliseconds
    }
    return nil
  }
}
