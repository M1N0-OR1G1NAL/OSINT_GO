//
//  NetworkEvent.swift
//  RECON-GO
//
//  Created by M1N0-H1DDEN on 06.12.2025.
//


// NetworkMonitorView.swift (preview / simulated)
import SwiftUI

struct NetworkEvent: Identifiable {
    let id = UUID()
    let time: Date
    let app: String
    let remote: String
    let risk: String
    let reason: String
}

struct NetworkMonitorView: View {
    @State private var events: [NetworkEvent] = [
        NetworkEvent(time: Date(), app: "chrome", remote: "93.184.216.34:443", risk: "low", reason: "web browsing")
    ]

    var body: some View {
        VStack {
            List(events) { e in
                HStack {
                    VStack(alignment: .leading) {
                        Text(e.app).bold()
                        Text(e.remote).font(.caption)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(e.risk.uppercased())
                            .foregroundColor(e.risk == "high" ? .red : .green)
                        Text(e.reason).font(.caption2)
                    }
                }
            }
            .listStyle(.plain)

            Button("Simulate suspicious") {
                let ev = NetworkEvent(time: Date(), app: "unknown_updater", remote: "203.0.113.77:443", risk: "high", reason: "suspicious telemetry")
                events.insert(ev, at: 0)
            }
        }
        .padding()
        .frame(minWidth: 420, minHeight: 320)
    }
}