import Foundation

public enum SessionRole: String, CaseIterable, Identifiable, Sendable {
  case phoneMicrophone
  case macSpeaker

  public var id: String { rawValue }
}
