//
//  SecurityEngine.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import Foundation
import Combine

final class SecurityEngine: ObservableObject {
    static let shared = SecurityEngine()
    
    // MARK: - Published data
    
    @Published var devices: [Device] = []
    @Published var vpnProfiles: [VPNProfile] = []
    @Published var processes: [ProcessItem] = []
    @Published var connections: [ConnectionItem] = []
    @Published var privacyRules: [PrivacyRule] = []
    
    @Published var cpuLoad: Double = 0
    @Published var memoryLoad: Double = 0
    @Published var networkInKBps: Double = 0
    @Published var networkOutKBps: Double = 0
    
    private var timer: AnyCancellable?
    private let ubiquitousStore = NSUbiquitousKeyValueStore.default
    
    private init() {
        loadInitialData()
        startSimulation()
        setupiCloudSync()
    }
    
    // MARK: - Initial data
    
    private func loadInitialData() {
        // Lze načítat z diskového JSONu / CloudKitu – tady rovnou dummy
        devices = [
            Device(id: UUID(), name: "Home Router", ipAddress: "192.168.0.1", os: "OpenWRT", isOnline: true, lastSeen: Date(), isTrusted: true),
            Device(id: UUID(), name: "Můj MacBook", ipAddress: "192.168.0.10", os: "macOS", isOnline: true, lastSeen: Date(), isTrusted: true),
            Device(id: UUID(), name: "iPhone", ipAddress: "192.168.0.20", os: "iOS", isOnline: true, lastSeen: Date(), isTrusted: true)
        ]
        
        vpnProfiles = [
            VPNProfile(id: UUID(), name: "Self-hosted VPN (WireGuard)", serverAddress: "vpn.mojedomena.cz", isActive: false, usesTor: false, autoConnect: true),
            VPNProfile(id: UUID(), name: "TOR+VPN Chain", serverAddress: "tor-gw.mojedomena.cz", isActive: false, usesTor: true, autoConnect: false)
        ]
        
        privacyRules = [
            PrivacyRule(id: UUID(), pattern: "google-analytics.com", isEnabled: true, ruleType: .tracker),
            PrivacyRule(id: UUID(), pattern: "doubleclick.net", isEnabled: true, ruleType: .ad),
            PrivacyRule(id: UUID(), pattern: "facebook.com/tr", isEnabled: true, ruleType: .tracker),
            PrivacyRule(id: UUID(), pattern: "openai.com/*bot*", isEnabled: true, ruleType: .aiBot)
        ]
        
        generateRandomProcesses()
        generateRandomConnections()
    }
    
    // MARK: - Simulation
    
    private func startSimulation() {
        timer = Timer
            .publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func tick() {
        // Simulace systémových metrik
        cpuLoad = Double.random(in: 5...95)
        memoryLoad = Double.random(in: 20...90)
        networkInKBps = Double.random(in: 10...500)
        networkOutKBps = Double.random(in: 5...400)
        
        updateProcesses()
        updateConnections()
    }
    
    private func generateRandomProcesses() {
        let names = [
            "WindowServer", "kernel_task", "syspolicyd", "mds", "mdworker",
            "Google Chrome", "Safari", "Telegram", "Discord", "tor", "ssh", "python3",
            "UnknownMiner", "weird_process", "AITrackerDaemon"
        ]
        
        processes = names.enumerated().map { idx, name in
            let cpu = Double.random(in: 0...40)
            let ram = Double.random(in: 10...800)
            let suspicious = isSuspiciousProcess(name: name, cpu: cpu, ram: ram)
            return ProcessItem(
                id: Int32(idx + 100),
                name: name,
                cpuUsage: cpu,
                memoryUsageMB: ram,
                isSuspicious: suspicious,
                path: "/usr/local/bin/\(name.lowercased().replacingOccurrences(of: " ", with: "_"))"
            )
        }
    }
    
    private func generateRandomConnections() {
        let ips = [
            "142.250.184.78",  // google
            "151.101.1.69",    // fastly
            "104.21.37.123",   // cloudflare
            "185.220.101.1",   // tor exit (příklad)
            "23.45.67.89"      // random
        ]
        
        let ports = [80, 443, 53, 9001, 51820]
        let protocols = ["TCP", "UDP"]
        
        connections = (0..<8).map { _ in
            let ip = ips.randomElement()!
            let port = ports.randomElement()!
            let proto = protocols.randomElement()!
            let isBlocked = isSuspiciousConnection(ip: ip, port: port)
            return ConnectionItem(
                id: UUID(),
                remoteAddress: ip,
                remotePort: port,
                protocolName: proto,
                isBlocked: isBlocked,
                note: isBlocked ? "Match privacy rule / suspicious port" : nil
            )
        }
    }
    
    private func updateProcesses() {
        // Simulovaný mírný drift hodnot
        processes = processes.map { proc in
            var p = proc
            p.cpuUsage = min(100, max(0, p.cpuUsage + Double.random(in: -5...5)))
            p.memoryUsageMB = max(5, p.memoryUsageMB + Double.random(in: -20...20))
            p.isSuspicious = isSuspiciousProcess(name: p.name, cpu: p.cpuUsage, ram: p.memoryUsageMB)
            return p
        }
    }
    
    private func updateConnections() {
        // Občas přegenerujeme
        if Bool.random() {
            generateRandomConnections()
        }
    }
    
    // MARK: - Heuristiky (čistě demonstrace)
    
    private func isSuspiciousProcess(name: String, cpu: Double, ram: Double) -> Bool {
        let lower = name.lowercased()
        let keywords = ["miner", "crypto", "hack", "keylog", "rat", "backdoor", "aiTrackerDaemon".lowercased()]
        if keywords.contains(where: { lower.contains($0) }) { return true }
        if cpu > 70 && ram > 400 { return true }
        return false
    }
    
    private func isSuspiciousConnection(ip: String, port: Int) -> Bool {
        // Jednoduchá heuristika – porty mimo běžné webové/DoH atd.
        if port == 9001 { return true } // typický TOR relay port (jen příklad)
        if port > 50000 { return true }
        // Můžes rozšířit o lookup v blacklistu domén/IP
        return false
    }
    
    // MARK: - VPN logika (simulovaná)
    
    func toggleVPN(profile: VPNProfile) {
        if let idx = vpnProfiles.firstIndex(where: { $0.id == profile.id }) {
            // Deaktivuj všechny ostatní
            vpnProfiles = vpnProfiles.map { VPNProfile(id: $0.id, name: $0.name, serverAddress: $0.serverAddress, isActive: false, usesTor: $0.usesTor, autoConnect: $0.autoConnect) }
            // Přepni tento
            vpnProfiles[idx].isActive.toggle()
            saveToiCloud()
        }
    }
    
    // MARK: - Privacy rules
    
    func toggleRule(_ rule: PrivacyRule) {
        if let idx = privacyRules.firstIndex(where: { $0.id == rule.id }) {
            privacyRules[idx].isEnabled.toggle()
            saveToiCloud()
        }
    }
    
    // MARK: - iCloud sync (Key-Value demo)
    
    private func setupiCloudSync() {
        NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: ubiquitousStore,
            queue: .main
        ) { [weak self] _ in
            self?.loadFromiCloud()
        }
        
        loadFromiCloud()
    }
    
    private func saveToiCloud() {
        let encoder = JSONEncoder()
        if let vpnData = try? encoder.encode(vpnProfiles) {
            ubiquitousStore.set(vpnData, forKey: "vpnProfiles")
        }
        if let rulesData = try? encoder.encode(privacyRules) {
            ubiquitousStore.set(rulesData, forKey: "privacyRules")
        }
        ubiquitousStore.synchronize()
    }
    
    private func loadFromiCloud() {
        let decoder = JSONDecoder()
        if let vpnData = ubiquitousStore.data(forKey: "vpnProfiles"),
           let decoded = try? decoder.decode([VPNProfile].self, from: vpnData) {
            vpnProfiles = decoded
        }
        if let rulesData = ubiquitousStore.data(forKey: "privacyRules"),
           let decoded = try? decoder.decode([PrivacyRule].self, from: rulesData) {
            privacyRules = decoded
        }
    }
}
