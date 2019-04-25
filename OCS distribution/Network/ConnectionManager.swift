//
//  ConnectionManager.swift
//  OCS distribution
//
//  Created by Sergey on 25/04/2019.
//  Copyright © 2019 PyrovSergey. All rights reserved.
//

import Foundation
import Reachability

class ConnectionManager: NSObject {
    var reachability: Reachability!
    static let sharedInstance: ConnectionManager = {
        return ConnectionManager()
    }()
    override init() {
        super.init()
        // Initialise reachability
        reachability = Reachability()!
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (ConnectionManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection != .none {
            completed(ConnectionManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection == .none {
            completed(ConnectionManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection == .cellular {
            completed(ConnectionManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection == .wifi {
            completed(ConnectionManager.sharedInstance)
        }
    }
}
