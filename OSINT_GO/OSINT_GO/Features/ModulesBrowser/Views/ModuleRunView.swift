//
//  ModuleRunView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI
import SwiftData

struct ModuleRunView: View {
    let target: Target
    let module: OsintModule
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isRunning = false
    @State private var result: ModuleResult?
    @State private var progress: Double = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: module.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(module.color)
                    VStack(alignment: .leading) {
                        Text(module.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(target.value)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Progress
                if isRunning {
                    ProgressView(value: progress)
                        .padding()
                }
                
                // Results
                if let result = result {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            RiskBadgeView(score: result.riskScore)
                            Text(result.summary)
                                .font(.headline)
                            ForEach(result.details.keys.sorted(), id: \.self) { key in
                                DetailRow(key: key, value: "\(result.details[key] ?? "")")
                            }
                        }
                        .padding()
                    }
                }
                
                // Controls
                HStack {
                    Button("Zrušit") { dismiss() }
                        .buttonStyle(.bordered)
                    
                    Button(isRunning ? "Zastavit" : "SPUSTIT MODUL") {
                        if isRunning {
                            // Cancel task logic
                        } else {
                            runModule()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isRunning)
                }
            }
            .padding()
            .navigationTitle("Spustit modul")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func runModule() {
        isRunning = true
        Task {
            do {
                let context = OsintContext()
                let moduleResult = try await module.execute(on: target, context: context)
                await MainActor.run {
                    target.results.append(moduleResult)
                    result = moduleResult
                    isRunning = false
                }
            } catch {
                await MainActor.run {
                    isRunning = false
                    print("Error: \(error)")
                }
            }
        }
    }
}
