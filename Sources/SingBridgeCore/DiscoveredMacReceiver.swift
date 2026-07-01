import Foundation

public struct DiscoveredMacReceiver: Equatable, Identifiable, Sendable {
  public var id: String
  public var name: String
  public var host: String
  public var port: UInt16
  public var lastSeen: Date

  public init(id: String, name: String, host: String, port: UInt16, lastSeen: Date = Date()) {
    self.id = id
    self.name = name
    self.host = host
    self.port = port
    self.lastSeen = lastSeen
  }

  public var endpointText: String {
    "\(host):\(port)"
  }
}
