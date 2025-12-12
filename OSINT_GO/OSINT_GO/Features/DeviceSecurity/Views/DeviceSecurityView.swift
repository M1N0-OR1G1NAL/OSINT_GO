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
                    
                    SectionHeaderView(title: "Device Information", icon: "iphone")
                    
                    DeviceInfoCard(deviceInfo: viewModel.deviceInfo)
                    
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

struct DeviceInfoCard: View {
    let deviceInfo: DeviceSecurityViewModel.DeviceInfo
    
    var body: some View {
        VStack(spacing: 12) {
            InfoRow(icon: "iphone", label: "Device Model", value: deviceInfo.deviceModel)
            InfoRow(icon: "apple.logo", label: "iOS Version", value: deviceInfo.iosVersion)
            InfoRow(icon: "person.text.rectangle", label: "Device Name", value: deviceInfo.deviceName)
            InfoRow(icon: "phone.fill", label: "Phone Number", value: deviceInfo.phoneNumber)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
        }
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

struct RecommendationsList: View {
    let recommendations: [String]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(recommendations.enumerated()), id: \.offset) { index, recommendation in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.title3)
                    
                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

struct QuickActionsGrid: View {
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            QuickActionButton(
                title: "Check Updates",
                icon: "arrow.triangle.2.circlepath",
                color: .blue
            ) {
                // Open Settings app
                if let url = URL(string: "App-Prefs:root=General&path=SOFTWARE_UPDATE_LINK") {
                    UIApplication.shared.open(url)
                }
            }
            
            QuickActionButton(
                title: "Security Settings",
                icon: "gear.badge.checkmark",
                color: .green
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            
            QuickActionButton(
                title: "Privacy Report",
                icon: "shield.lefthalf.filled",
                color: .purple
            ) {
                // Could open privacy report in future
            }
            
            QuickActionButton(
                title: "App Permissions",
                icon: "hand.raised.fill",
                color: .orange
            ) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: 80)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
