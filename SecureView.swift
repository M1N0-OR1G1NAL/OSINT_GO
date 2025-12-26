//
//  SecureView.swift
//  Secure_Recon
//
//  Created by M1N0-H1DDEN on 29.11.2025.
//


import SwiftUI

struct SecureView: View {
    @EnvironmentObject var engine: SecurityEngine
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                Text("SECURE MONITOR")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                
                Text("Běžící procesy")
                    .foregroundColor(.green)
                    .font(.headline)
                
                List {
                    ForEach(engine.processes) { p in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(p.name)
                                    .foregroundColor(p.isSuspicious ? .red : .green)
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
                    }
                }
                .background(Color.black)
                
                Text("Anti-tracking / Anti-cookie rules")
                    .foregroundColor(.green)
                    .font(.headline)
                
                List {
                    ForEach(engine.privacyRules) { rule in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rule.pattern)
                                Text(rule.ruleType.rawValue.uppercased())
                                    .font(.caption2)
                            }
                            .foregroundColor(.green)
                            Spacer()
                            Toggle("EN", isOn: Binding(
                                get: { rule.isEnabled },
                                set: { _ in engine.toggleRule(rule) }
                            ))
                            .labelsHidden()
                        }
                    }
                }
                .background(Color.black)
            }
            .padding()
        }
    }
}
