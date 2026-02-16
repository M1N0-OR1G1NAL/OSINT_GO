//
//  InvestigationDetailView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct InvestigationDetailView: View {
    @ObservedObject var investigation: Investigation
    @StateObject private var viewModel = InvestigationDetailViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()

            VStack(spacing: 16) {
                // glass header
                GlassHeader(
                    title: investigation.name,
                    subtitle: "Risk score \(String(format: "%.1f", investigation.riskScore))"
                )

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 18)

                    VStack {
                        Picker("", selection: $selectedTab) {
                            Text("Targets").tag(0)
                            Text("Timeline").tag(1)
                            Text("Graph").tag(2)
                            Text("Results").tag(3)
                            Text("Notes").tag(4)
                        }
                        .pickerStyle(.segmented)
                        .padding()

                        Group {
                            switch selectedTab {
                            case 0: TargetsTabView(investigation: investigation)
                            case 1: TimelineTabView(investigation: investigation)
                            case 2: GraphTabView(investigation: investigation)
                            case 3: ResultsTabView(investigation: investigation)
                            default: NotesTabView(investigation: investigation)
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
                .padding(.horizontal)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)

                Button {
                    Task {
                        await viewModel.runQuickRecon(on: investigation)
                    }
                } label: {
                    Label("Quick Recon", systemImage: "bolt.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: .cyan.opacity(0.6), radius: 15, x: 0, y: 8)
                }
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
