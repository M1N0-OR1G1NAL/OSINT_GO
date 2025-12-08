//
//  DeviceSecurityViewModel.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import UIKit

@MainActor
@Observable
class DeviceSecurityViewModel {
    var status: SecurityStatus = .checking
    var score: Double = 0.0
    var checks: [SecurityCheck] = []
    var recommendations: [String] = []
    
    enum SecurityStatus {
        case checking, secure, warning, compromised
        
        var title: String {
            switch self {
            case .checking: return "Checking..."
            case .secure: return "Secure"
            case .warning: return "Warnings"
            case .compromised: return "Compromised"
            }
        }
        
        var icon: String {
            switch self {
            case .checking: return "shield"
            case .secure: return "lock.shield.fill"
            case .warning: return "exclamationmark.shield"
            case .compromised: return "xmark.shield"
            }
        }
        
        var color: Color {
            switch self {
            case .checking: return .blue
            case .secure: return .green
            case .warning: return .orange
            case .compromised: return .red
            }
        }
    }
    
    func refresh() async {
        // Simulate async security checks
        checks = [
            SecurityCheck(name: "iOS Version", status: .pass, icon: "checkmark.circle"),
            SecurityCheck(name: "Jailbreak", status: .pass, icon: "iphone"),
            SecurityCheck(name: "VPN Active", status: .warning, icon: "network"),
            SecurityCheck(name: "Biometrics", status: .pass, icon: "faceid")
        ]
        
        score = 0.85
        status = .secure
        recommendations = [
            "Update to latest iOS",
            "Enable Lockdown Mode for high-risk ops",
            "Review installed profiles"
        ]
    }
}

struct SecurityCheck: Identifiable {
    let id = UUID()
    let name: String
    let status: CheckStatus
    let icon: String
    
    enum CheckStatus {
        case pass, warning, fail
        
        var color: Color {
            switch self {
            case .pass: return .green
            case .warning: return .orange
            case .fail: return .red
            }
        }
    }
}

struct SecurityCheckCard: View {
    let check: SecurityCheck
    
    var body: some View {
        VStack {
            Image(systemName: check.icon)
                .font(.title2)
                .foregroundStyle(check.status.color)
            Text(check.name)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
