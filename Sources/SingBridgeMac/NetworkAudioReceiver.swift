import Foundation
import Network
import SingBridgeCore

final class NetworkAudioReceiver {
  var onStateChange: ((ConnectionState) -> Void)?
  var onPacket: ((AudioPacket) -> Void)?
  var onError: ((String) -> Void)?

  private let queue = DispatchQueue(label: "SingBridge.NetworkAudioReceiver")
  private var listener: NWListener?
  private var connection: NWConnection?
  private var decoder = StreamPacketDecoder()

  func start(port: UInt16 = SingBridgeNetworkDefaults.port) throws {
    stop()

    let listener = try NWListener(
      using: .tcp,
      on: NWEndpoint.Port(rawValue: port) ?? NWEndpoint.Port(integerLiteral: port)
    )
    listener.service = NWListener.Service(
      name: SingBridgeNetworkDefaults.serviceName,
      type: SingBridgeNetworkDefaults.serviceType
    )

    listener.stateUpdateHandler = { [weak self] state in
      guard let self else { return }
      switch state {
      case .ready:
        self.onStateChange?(.searching)
      case .failed(let error):
        self.onError?(error.localizedDescription)
        self.onStateChange?(.failed(message: error.localizedDescription))
      case .cancelled:
        self.onStateChange?(.idle)
      default:
        break
      }
    }

    listener.newConnectionHandler = { [weak self] connection in
      self?.accept(connection)
    }

    self.listener = listener
    listener.start(queue: queue)
  }

  func stop() {
    connection?.cancel()
    connection = nil
    listener?.cancel()
    listener = nil
    decoder.reset()
  }

  private func accept(_ connection: NWConnection) {
    self.connection?.cancel()
    self.connection = connection
    decoder.reset()

    connection.stateUpdateHandler = { [weak self] state in
      guard let self else { return }
      switch state {
      case .ready:
        self.onStateChange?(.connected(deviceName: "iPhone", latencyMilliseconds: 0))
        self.receiveLoop(on: connection)
      case .failed(let error):
        self.onError?(error.localizedDescription)
        self.onStateChange?(.failed(message: error.localizedDescription))
      case .cancelled:
        self.onStateChange?(.searching)
      default:
        break
      }
    }

    connection.start(queue: queue)
  }

  private func receiveLoop(on connection: NWConnection) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 64 * 1024) { [weak self] data, _, isComplete, error in
      guard let self else { return }

      if let data, !data.isEmpty {
        let packets = self.decoder.append(data)
        packets.forEach { self.onPacket?($0) }
      }

      if let error {
        self.onError?(error.localizedDescription)
        self.onStateChange?(.failed(message: error.localizedDescription))
        return
      }

      if isComplete {
        self.onStateChange?(.searching)
        return
      }

      self.receiveLoop(on: connection)
    }
  }
}
