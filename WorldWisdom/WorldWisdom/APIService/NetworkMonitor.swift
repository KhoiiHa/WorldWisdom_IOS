//
//  NetworkMonitor .swift
//  WorldWisdom
//
//  Created by Vu Minh Khoi Ha on 14.02.25.
//

import Network
import Combine

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    var isConnected: Bool = false {
        didSet {
            onStatusChange?(isConnected)
        }
    }

    var onStatusChange: ((Bool) -> Void)?

    init() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.isConnected = true
                }
                #if DEBUG
                print("🌐 Verbindung hergestellt (Debug)")
                #endif
            } else {
                DispatchQueue.main.async {
                    self.isConnected = false
                }
                #if DEBUG
                print("⚠️ Keine Internetverbindung (Debug)")
                #endif
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
