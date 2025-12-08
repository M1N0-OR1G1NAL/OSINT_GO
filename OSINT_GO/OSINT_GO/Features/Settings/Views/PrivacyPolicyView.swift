//
//  PrivacyPolicyView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 08.12.2025.
//


import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("""
                Atlas OSINT neposílá žádná data na servery. Vše probíhá lokálně na zařízení.
                
                • Všechny OSINT moduly používají veřejná API
                • Data uložená v šifrované SwiftData databázi
                • Anonymní telemetry (volitelné) - pouze počet spuštění
                • Žádné osobní údaje nejsou sbírány
                
                Používáním souhlasíte s legálním OSINT použitím.
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy")
    }
}
