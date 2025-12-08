//
//  TargetsTabView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import SwiftData

struct TargetsTabView: View {
    let investigation: Investigation
    
    var body: some View {
        List {
            ForEach(investigation.targets) { target in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: TargetType(rawValue: target.type)?.iconName ?? "questionmark")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text(target.label.isEmpty ? target.value : target.label)
                                .font(.headline)
                            Text(target.type)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        RiskBadgeView(score: targetRiskScore(for: target))
                    }
                    
                    if !target.results.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(target.results.prefix(3)) { result in
                                    ModuleResultChip(result: result)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func targetRiskScore(for target: Target) -> Double {
        let total = target.results.reduce(0) { $0 + $1.riskScore }
        return target.results.isEmpty ? 0 : total / Double(target.results.count)
    }
}

struct ModuleResultChip: View {
    let result: ModuleResult
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle")
            Text(result.moduleName)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .clipShape(Capsule())
    }
}
