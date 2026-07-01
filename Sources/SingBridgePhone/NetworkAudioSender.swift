import Foundation
import Network
import SingBridgeCore

final class NetworkAudioSender {
  var onStateChange: ((ConnectionState) -> Void)?
  var onError: ((String) -> Void)?

  private let queue = DispatchQueue(label: "SingBridge.NetworkAudioSender")
  private var connection: NWConnection?

  func connect(host: String, port: UInt16 = SingBridgeNetworkDefaults.port) {
    stop()

    let connection = NWConnection(
      host: NWEndpoint.Host(host),
      port: NWEndpoint.Port(rawValue: port) ?? NWEndpoint.Port(integerLiteral: port),
      using: .tcp
    )
    self.connection = connection
    onStateChange?(.connecting(deviceName: host))

    connection.stateUpdateHandler = { [weak self] state in
      guard let self else { return }
      switch state {
      case .ready:
        self.onStateChange?(.connected(deviceName: host, latencyMilliseconds: 0))
      case .failed(let error):
        self.onError?(error.localizedDescription)
        self.onStateChange?(.failed(message: error.localizedDescription))
      case .cancelled:
        self.onStateChange?(.idle)
      default:
        break
      }
    }

    connection.start(queue: queue)
  }

  func send(packet: AudioPacket) {
    guard let connection else { return }
    let frame = StreamPacketEncoder.frame(packet)
    connection.send(content: frame, completion: .contentProcessed { [weak self] error in
      if let error {
        self?.onError?(error.localizedDescription)
      }
    })
  }

  func stop() {
    connection?.cancel()
    connection = nil
  }
}
