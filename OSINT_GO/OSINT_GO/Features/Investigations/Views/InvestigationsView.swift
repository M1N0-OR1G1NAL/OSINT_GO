//
//  InvestigationsView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import SwiftData

struct InvestigationsView: View {
    @Query(sort: \Investigation.createdAt, order: .reverse)
    private var investigations: [Investigation]

    @Environment(\.modelContext) private var modelContext
    @State private var showingNewInvestigation = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.ignoresSafeArea()

                if investigations.isEmpty {
                    EmptyStateView(
                        title: "No Investigations",
                        message: "Create your first OSINT case and start linking domains, IPs, emails and more.",
                        icon: "magnifyingglass.circle"
                    )
                    .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(investigations) { investigation in
                                InvestigationCardView(investigation: investigation)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Investigations")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewInvestigation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showingNewInvestigation) {
                NewInvestigationView()
            }
        }
    }
}

struct InvestigationCardView: View {
    @ObservedObject var investigation: Investigation

    @State private var isPressed = false

    var body: some View {
        NavigationLink {
            InvestigationDetailView(investigation: investigation)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.4),
                                        .white.opacity(0.05),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.45), radius: 18, x: 0, y: 14)
                    .shadow(color: .white.opacity(0.2), radius: 6, x: 0, y: -2)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(investigation.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        RiskBadgeView(score: investigation.riskScore)
                    }

                    Text(investigation.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))

                    HStack {
                        Label("\(investigation.targets.count) targets",
                              systemImage: "target")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.85))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(16)
            }
            .rotation3DEffect(
                .degrees(isPressed ? 6 : 0),
                axis: (x: -0.3, y: 0.8, z: 0),
                perspective: 0.6
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
            .onLongPressGesture(minimumDuration: 0.05, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
        }
        .buttonStyle(.plain)
    }
}
