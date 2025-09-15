//
//  ssc2App.swift
//  ssc2
//
//  Created by Diogo Assumpcao on 4/8/25.
//

import SwiftUI

class AppState: ObservableObject {
    // IPv4 Calculator State
    @Published var ipv4Octet1: String = "" {
        didSet {
            // Ensure value is 0-255
            if let value = Int(ipv4Octet1), value > 255 {
                ipv4Octet1 = "255"
            }
        }
    }
    @Published var ipv4Octet2: String = "" {
        didSet {
            // Ensure value is 0-255
            if let value = Int(ipv4Octet2), value > 255 {
                ipv4Octet2 = "255"
            }
        }
    }
    @Published var ipv4Octet3: String = "" {
        didSet {
            // Ensure value is 0-255
            if let value = Int(ipv4Octet3), value > 255 {
                ipv4Octet3 = "255"
            }
        }
    }
    @Published var ipv4Octet4: String = "" {
        didSet {
            // Ensure value is 0-255
            if let value = Int(ipv4Octet4), value > 255 {
                ipv4Octet4 = "255"
            }
        }
    }
    @Published var ipv4CidrPrefix: Double = 22
    
    // IPv6 Calculator State
    @Published var ipv6Address: String = ""
    @Published var ipv6CidrPrefix: Double = 64
    
    // Reset functions
    func resetIPv4Fields() {
        ipv4Octet1 = ""
        ipv4Octet2 = ""
        ipv4Octet3 = ""
        ipv4Octet4 = ""
        ipv4CidrPrefix = 22
    }
    
    func resetIPv6Fields() {
        ipv6Address = ""
        ipv6CidrPrefix = 64
    }
}

@main
struct ssc2App: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
