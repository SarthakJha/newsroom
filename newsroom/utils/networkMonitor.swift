//
//  networkMonitor.swift
//  newsroom
//
//  Created by Sarthak Jha on 09/01/23.
//

import NotificationCenter
import Network

final class NetworkMonitor {
    public static let shared = NetworkMonitor()
    
    let monitor = NWPathMonitor()
      private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { return monitor.currentPath.status == .satisfied }
      var isReachableOnCellular: Bool = true

      func startMonitoring() {
          monitor.pathUpdateHandler = { [weak self] path in
              self?.status = path.status
              self?.isReachableOnCellular = path.isExpensive

              if path.status == .satisfied {
                  print("We're connected!")
              } else {
                  print("No connection.")
                  NotificationCenter.default.post(name: NSNotification.Name("isConnected"), object: nil)
              }
              print(path.isExpensive)
          }

          let queue = DispatchQueue(label: "NetworkMonitor")
          monitor.start(queue: queue)
      }
    func recheckConnection(){
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive

            if path.status == .satisfied {
                print("We're connected!")
                // post connected notification
            } else {
                print("No connection.")
                // post disconnected notification
            }
            print(path.isExpensive)
        }
    }

      func stopMonitoring() {
          monitor.cancel()
      }
}
