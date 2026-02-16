//
//  ResultsTabView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct ResultsTabView: View {
    let investigation: Investigation
    
    private var allResults: [(Target, ModuleResult)] {
        var results: [(Target, ModuleResult)] = []
        for target in investigation.targets {
            for result in target.results {
                results.append((target, result))
            }
        }
        return results.sorted { $0.1.timestamp > $1.1.timestamp }
    }
    
    var body: some View {
        ScrollView {
            if allResults.isEmpty {
                EmptyStateView(
                    title: "No Results Yet",
                    message: "Run OSINT modules on your targets to see results here",
                    icon: "doc.text.magnifyingglass"
                )
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(allResults.indices, id: \.self) { index in
                        ResultCard(target: allResults[index].0, result: allResults[index].1)
                    }
                }
                .padding()
            }
        }
    }
}

struct ResultCard: View {
    let target: Target
    let result: ModuleResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: TargetType(rawValue: target.type)?.iconName ?? "questionmark")
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading) {
                    Text(result.moduleName)
                        .font(.headline)
                    Text(target.value)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                RiskBadgeView(score: result.riskScore)
            }
            
            Text(result.summary)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Text(result.timestamp, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
