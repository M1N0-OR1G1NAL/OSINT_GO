//
//  DeviceSecurityView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct DeviceSecurityView: View {
    @StateObject private var viewModel = DeviceSecurityViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    SecurityStatusCard(status: viewModel.status, score: viewModel.score)
                    
                    SectionHeaderView(title: "Security Checks", icon: "checkmark.shield")
                    
                    SecurityChecksGrid(checks: viewModel.checks)
                    
                    SectionHeaderView(title: "Recommendations", icon: "lightbulb")
                    
                    RecommendationsList(recommendations: viewModel.recommendations)
                    
                    SectionHeaderView(title: "Quick Actions", icon: "bolt")
                    
                    QuickActionsGrid()
                }
                .padding()
            }
            .navigationTitle("Device Security")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.refresh()
            }
        }
    }
}

struct SecurityStatusCard: View {
    let status: SecurityStatus
    let score: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: status.icon)
                .font(.system(size: 64))
                .foregroundStyle(status.color)
            
            Text(status.title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            RiskBadgeView(score: score)
                .font(.title3)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SecurityChecksGrid: View {
    let checks: [SecurityCheck]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ForEach(checks) { check in
                SecurityCheckCard(check: check)
            }
        }
    }
}
