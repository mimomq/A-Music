import Foundation
import Network
import SingBridgeCore

final class MacReceiverDiscoveryService {
  var onReceiversChanged: (([DiscoveredMacReceiver]) -> Void)?
  var onError: ((String) -> Void)?

  private let queue = DispatchQueue(label: "SingBridge.MacReceiverDiscoveryService")
  private var browser: NWBrowser?
  private var receiversByID: [String: DiscoveredMacReceiver] = [:]
  private var endpointsByID: [String: NWEndpoint] = [:]

  func start() {
    stop()

    let descriptor = NWBrowser.Descriptor.bonjour(
      type: SingBridgeNetworkDefaults.serviceType,
      domain: nil
    )
    let browser = NWBrowser(for: descriptor, using: .tcp)
    self.browser = browser

    browser.stateUpdateHandler = { [weak self] state in
      guard let self else { return }
      if case .failed(let error) = state {
        self.onError?(error.localizedDescription)
      }
    }

    browser.browseResultsChangedHandler = { [weak self] results, _ in
      self?.updateReceivers(from: results)
    }

    browser.start(queue: queue)
  }

  func stop() {
    browser?.cancel()
    browser = nil
    receiversByID.removeAll()
    endpointsByID.removeAll()
    onReceiversChanged?([])
  }

  func endpoint(for receiver: DiscoveredMacReceiver) -> NWEndpoint? {
    endpointsByID[receiver.id]
  }

  private func updateReceivers(from results: Set<NWBrowser.Result>) {
    var nextReceiversByID: [String: DiscoveredMacReceiver] = [:]
    var nextEndpointsByID: [String: NWEndpoint] = [:]

    for result in results {
      guard let receiver = Self.receiver(from: result) else { continue }
      nextReceiversByID[receiver.id] = receiver
      nextEndpointsByID[receiver.id] = result.endpoint
    }

    receiversByID = nextReceiversByID
    endpointsByID = nextEndpointsByID
    let receivers = nextReceiversByID.values.sorted { $0.name < $1.name }
    onReceiversChanged?(receivers)
  }

  private static func receiver(from result: NWBrowser.Result) -> DiscoveredMacReceiver? {
    guard case .service(let name, let type, _, _) = result.endpoint else {
      return nil
    }

    let id = "\(name).\(type)"
    return DiscoveredMacReceiver(
      id: id,
      name: name.isEmpty ? SingBridgeNetworkDefaults.serviceName : name,
      host: name,
      port: SingBridgeNetworkDefaults.port
    )
  }
}
