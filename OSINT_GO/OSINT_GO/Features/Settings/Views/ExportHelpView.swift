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
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Export Complete", systemImage: "checkmark.circle.fill")
                            .font(.title2.bold())
                            .foregroundStyle(.green)
                        
                        Text("Your investigations have been exported successfully.")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Export Formats")
                            .font(.headline)
                        
                        ExportFormatRow(
                            format: "JSON",
                            description: "Machine-readable format for data analysis",
                            icon: "doc.text"
                        )
                        
                        ExportFormatRow(
                            format: "PDF",
                            description: "Human-readable report format",
                            icon: "doc.richtext"
                        )
                        
                        ExportFormatRow(
                            format: "CSV",
                            description: "Spreadsheet-compatible format",
                            icon: "tablecells"
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's Included")
                            .font(.headline)
                        
                        FeatureRow(icon: "target", text: "All investigation targets")
                        FeatureRow(icon: "chart.bar", text: "Module results and findings")
                        FeatureRow(icon: "clock", text: "Timeline events")
                        FeatureRow(icon: "link", text: "Relationship graphs")
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Security Note")
                            .font(.headline)
                        
                        Label {
                            Text("Exported data contains sensitive OSINT information. Store securely and handle according to applicable privacy laws.")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                        .padding()
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
            .navigationTitle("Export Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExportFormatRow: View {
    let format: String
    let description: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(format)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    ExportHelpView()
}
