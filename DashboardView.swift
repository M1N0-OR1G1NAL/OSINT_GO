//
//  DashboardView.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var engine: SecurityEngine
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black, .green.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("RECON DASHBOARD")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 16) {
                        MetricCard(title: "CPU LOAD", value: "\(Int(engine.cpuLoad)) %")
                        MetricCard(title: "RAM USAGE", value: "\(Int(engine.memoryLoad)) %")
                        MetricCard(title: "NET IN", value: "\(Int(engine.networkInKBps)) kB/s")
                        MetricCard(title: "NET OUT", value: "\(Int(engine.networkOutKBps)) kB/s")
                    }
                    
                    VPNStatusCard()
                    
                    Text("Podezřelé procesy")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                    
                    SuspiciousProcessList(processes: engine.processes.filter { $0.isSuspicious })
                    
                    Text("Blokovaná spojení")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.top, 8)
                    
                    BlockedConnectionsList(connections: engine.connections.filter { $0.isBlocked })
                }
                .padding()
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.green.opacity(0.7))
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.6), lineWidth: 1)
                .background(Color.black.opacity(0.6))
        )
    }
}

struct VPNStatusCard: View {
    @EnvironmentObject var engine: SecurityEngine
    
    var activeVPN: VPNProfile? {
        engine.vpnProfiles.first(where: { $0.isActive })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("VPN / PRIVACY TUNNEL")
                .font(.headline)
                .foregroundColor(.green)
            
            if let vpn = activeVPN {
                Text("Aktivní: \(vpn.name)")
                    .foregroundColor(.green)
                Text("Server: \(vpn.serverAddress)")
                    .foregroundColor(.green.opacity(0.8))
                if vpn.usesTor {
                    Text("Řetězení: TOR + VPN")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            } else {
                Text("VPN je odpojeno")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.7), lineWidth: 1)
                .background(Color.black.opacity(0.7))
        )
    }
}

struct SuspiciousProcessList: View {
    let processes: [ProcessItem]
    
    var body: some View {
        if processes.isEmpty {
            Text("Žádné zjevně podezřelé procesy.")
                .foregroundColor(.green.opacity(0.7))
                .font(.caption)
        } else {
            VStack(spacing: 8) {
                ForEach(processes) { p in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(p.name)
                                .foregroundColor(.red)
                            Text(p.path)
                                .font(.caption2)
                                .foregroundColor(.green.opacity(0.7))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("CPU \(Int(p.cpuUsage)) %")
                            Text("RAM \(Int(p.memoryUsageMB)) MB")
                        }
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.8))
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red.opacity(0.8), lineWidth: 1)
                            .background(Color.black.opacity(0.8))
                    )
                }
            }
        }
    }
}

struct BlockedConnectionsList: View {
    let connections: [ConnectionItem]
    
    var body: some View {
        if connections.isEmpty {
            Text("Žádná blokovaná spojení.")
                .foregroundColor(.green.opacity(0.7))
                .font(.caption)
        } else {
            VStack(spacing: 8) {
                ForEach(connections) { c in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(c.remoteAddress):\(c.remotePort)")
                            Text(c.protocolName)
                                .font(.caption2)
                        }
                        .foregroundColor(.green)
                        Spacer()
                        if let note = c.note {
                            Text(note)
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.7), lineWidth: 1)
                            .background(Color.black.opacity(0.8))
                    )
                }
            }
        }
    }
}
