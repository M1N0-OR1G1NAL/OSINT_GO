//
//  DevicesView.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import SwiftUI

struct DevicesView: View {
    @EnvironmentObject var engine: SecurityEngine
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("ZAŘÍZENÍ V SÍTI")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                List {
                    ForEach(engine.devices) { d in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(d.name)
                                    .foregroundColor(d.isTrusted ? .green : .orange)
                                Text("\(d.ipAddress) · \(d.os)")
                                    .font(.caption2)
                                    .foregroundColor(.green.opacity(0.7))
                            }
                            Spacer()
                            Circle()
                                .fill(d.isOnline ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .background(Color.black)
            }
            .padding()
        }
    }
}
