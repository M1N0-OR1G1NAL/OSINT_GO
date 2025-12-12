//
//  ExportHelpView.swift
//  OSINT_GO
//
//  Created by M1N0-H1DDEN on 12.12.2025.
//


import SwiftUI

struct ExportHelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Export Format") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Investigations are exported as JSON files")
                            .font(.body)
                        Text("Each export includes:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Label("Export date and app version", systemImage: "calendar")
                            Label("Investigation metadata", systemImage: "folder")
                            Label("Target information", systemImage: "target")
                            Label("Module results and risk scores", systemImage: "chart.bar")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("File Location") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export files are saved to:")
                            .font(.body)
                        Text("Documents/OSINT_Export_[timestamp].json")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Usage") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Share exports via Files app", systemImage: "square.and.arrow.up")
                        Label("Import on another device", systemImage: "square.and.arrow.down")
                        Label("Archive for compliance", systemImage: "archivebox")
                        Label("Backup before app reinstall", systemImage: "externaldrive")
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Privacy & Security") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("⚠️ Export files contain sensitive OSINT data")
                            .font(.body)
                            .foregroundStyle(.orange)
                        Text("Store exports securely and comply with data protection laws (GDPR, etc.)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Export Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExportHelpView()
}
