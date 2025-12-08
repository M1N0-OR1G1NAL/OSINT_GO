//
//  RiskBadgeView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct RiskBadgeView: View {
    let score: Double
    
    private var color: Color {
        switch score {
        case 0..<0.3: return .green
        case 0.3..<0.7: return .orange
        default: return .red
        }
    }
    
    private var label: String {
        switch score {
        case 0..<0.3: return "Low"
        case 0.3..<0.7: return "Medium"
        default: return "High"
        }
    }
    
    var body: some View {
        Label("\(label) Risk (\(score, specifier: "%.1f"))", systemImage: "shield")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
