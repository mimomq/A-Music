import Foundation

public struct DeviceIdentity: Equatable, Identifiable, Sendable {
  public var id: UUID
  public var name: String
  public var role: SessionRole

  public init(id: UUID = UUID(), name: String, role: SessionRole) {
    self.id = id
    self.name = name
    self.role = role
  }
}
