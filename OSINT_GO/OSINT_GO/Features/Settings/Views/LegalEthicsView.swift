//
//  LegalEthicsView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct LegalEthicsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Legal & Ethics Guidelines")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    LegalRuleView(
                        icon: "checkmark.shield",
                        title: "Pouze veřejné zdroje",
                        description: "Všechny moduly používají pouze veřejně dostupná API a data bez scrapování chráněného obsahu."
                    )
                    
                    LegalRuleView(
                        icon: "person.2",
                        title: "Žádné sledování osob",
                        description: "Aplikace neprovádí real-time trackování ani sběr osobních údajů bez explicitního souhlasu."
                    )
                    
                    LegalRuleView(
                        icon: "globe",
                        title: "Respektování ToS",
                        description: "Všechny API volání respektují Terms of Service poskytovatelů (rate limits, klíče)."
                    )
                    
                    LegalRuleView(
                        icon: "lock.shield",
                        title: "Lokální šifrovaná DB",
                        description: "Všechna data ukládána lokálně v šifrované SwiftData databázi."
                    )
                }
                .padding()
            }
            .navigationTitle("Právní rámec")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Rozumím") { dismiss() }
                }
            }
        }
    }
}

struct LegalRuleView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
