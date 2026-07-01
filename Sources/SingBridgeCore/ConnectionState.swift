import Foundation

public enum ConnectionState: Equatable, Sendable {
  case idle
  case searching
  case connecting(deviceName: String)
  case connected(deviceName: String, latencyMilliseconds: Int)
  case failed(message: String)

  public var isConnected: Bool {
    if case .connected = self {
      return true
    }
    return false
  }

  public var displayText: String {
    switch self {
    case .idle:
      "Ready"
    case .searching:
      "Searching"
    case .connecting(let deviceName):
      "Connecting to \(deviceName)"
    case .connected(let deviceName, let latencyMilliseconds):
      "\(deviceName) - \(latencyMilliseconds) ms"
    case .failed(let message):
      message
    }
  }
}
