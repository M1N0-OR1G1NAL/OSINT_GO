//
//  TermsView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms of Service")
                    .font(.largeTitle.bold())
                    .padding(.bottom, 8)
                
                Group {
                    SectionTitle("1. Acceptance of Terms")
                    SectionText("By accessing and using OSINT GO, you accept and agree to be bound by the terms and provision of this agreement.")
                    
                    SectionTitle("2. Use License")
                    SectionText("Permission is granted to use OSINT GO for legitimate open-source intelligence gathering activities in compliance with applicable laws.")
                    
                    SectionTitle("3. Legal Compliance")
                    SectionText("Users must:")
                    BulletPoint("Comply with all applicable laws and regulations")
                    BulletPoint("Respect privacy rights and data protection laws (GDPR, etc.)")
                    BulletPoint("Obtain necessary permissions before conducting investigations")
                    BulletPoint("Use the tool for lawful purposes only")
                    
                    SectionTitle("4. Prohibited Activities")
                    SectionText("Users must NOT:")
                    BulletPoint("Engage in unauthorized access to systems or data")
                    BulletPoint("Violate terms of service of third-party platforms")
                    BulletPoint("Use the tool for harassment or stalking")
                    BulletPoint("Distribute malware or conduct harmful activities")
                    
                    SectionTitle("5. Subscription Services")
                    SectionText("Subscription-based features include:")
                    BulletPoint("AI-powered OSINT engines")
                    BulletPoint("Advanced module capabilities")
                    BulletPoint("Priority support")
                    BulletPoint("Extended data retention")
                    
                    SectionTitle("6. Data Privacy")
                    SectionText("All investigation data is stored locally on your device with encryption. We do not access or transmit your investigation data unless you explicitly use cloud sync features.")
                    
                    SectionTitle("7. Disclaimer")
                    SectionText("OSINT GO is provided 'as is' without warranties. We are not liable for any misuse of the tool or consequences arising from OSINT activities.")
                    
                    SectionTitle("8. Changes to Terms")
                    SectionText("We reserve the right to modify these terms at any time. Continued use constitutes acceptance of modified terms.")
                    
                    SectionTitle("9. Contact")
                    SectionText("For questions about these terms, contact us through the app's support section.")
                }
                
                Text("Last Updated: December 2025")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SectionTitle: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }
}

private struct SectionText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

private struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.leading, 16)
    }
}

#Preview {
    NavigationView {
        TermsView()
    }
}
