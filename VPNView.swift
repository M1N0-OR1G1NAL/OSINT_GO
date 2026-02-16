//
//  VPNView.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import SwiftUI

struct VPNView: View {
    @EnvironmentObject var engine: SecurityEngine
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("VPN / TUNNELS")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                List {
                    ForEach(engine.vpnProfiles) { profile in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(profile.name)
                                    .foregroundColor(profile.isActive ? .green : .white)
                                Text(profile.serverAddress)
                                    .font(.caption2)
                                    .foregroundColor(.green.opacity(0.7))
                                if profile.usesTor {
                                    Text("TOR chain enabled")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            Spacer()
                            Button(profile.isActive ? "Disconnect" : "Connect") {
                                engine.toggleVPN(profile: profile)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                .background(Color.black)
            }
            .padding()
        }
    }
}
